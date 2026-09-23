import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import {
  ASR_TIMEOUT_MS,
  AUTHORIZED_GROQ_TRANSCRIBE_MODEL,
  AUTHORIZED_OPENAI_TRANSCRIBE_MODEL,
  getASRProvider,
} from "../lib/services/asr-provider";

const originalEnv = { ...process.env };

const audio = (type = "audio/webm") =>
  new File(["audio"], "founder-recording-name.webm", { type });

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });

function disableAll() {
  delete process.env.GROQ_API_KEY;
  delete process.env.GROQ_TRANSCRIBE_MODEL;
  delete process.env.OPENAI_API_KEY;
  delete process.env.OPENAI_TRANSCRIBE_MODEL;
}

function enableGroq() {
  process.env.GROQ_API_KEY = "test-groq-key";
  process.env.GROQ_TRANSCRIBE_MODEL =
    AUTHORIZED_GROQ_TRANSCRIBE_MODEL;
}

function enableOpenAI() {
  process.env.OPENAI_API_KEY = "test-openai-key";
  process.env.OPENAI_TRANSCRIBE_MODEL =
    AUTHORIZED_OPENAI_TRANSCRIBE_MODEL;

  // Text model must remain independent from transcription config.
  process.env.OPENAI_MODEL = "independent-text-model";
}

beforeEach(() => {
  process.env = { ...originalEnv };

  // Critical isolation:
  // never allow .env.local provider credentials to affect unit tests.
  disableAll();
});

afterEach(() => {
  process.env = { ...originalEnv };
  vi.unstubAllGlobals();
});

describe("R6 ASR provider routing", () => {
  it("fails closed when neither ASR provider has exact configuration", async () => {
    process.env.GROQ_API_KEY = "test-groq-key";
    process.env.GROQ_TRANSCRIBE_MODEL = "wrong-groq-model";

    process.env.OPENAI_API_KEY = "test-openai-key";
    process.env.OPENAI_TRANSCRIBE_MODEL = "wrong-openai-model";

    const fetchMock = vi.fn();
    vi.stubGlobal("fetch", fetchMock);

    await expect(
      getASRProvider().transcribe({ audio: audio() }),
    ).resolves.toMatchObject({
      success: false,
      provider: "fallback",
      errorCategory: "UNAVAILABLE",
    });

    expect(fetchMock).not.toHaveBeenCalled();
  });

  it.each(["id", "ms"] as const)(
    "uses Groq as primary with one multipart request for language=%s",
    async (language) => {
      enableGroq();
      enableOpenAI();

      let captured:
        | { url: string; init: RequestInit }
        | undefined;

      const fetchMock = vi.fn(
        async (url: string, init: RequestInit) => {
          captured = { url, init };
          return json({ text: "  Halo DUTA  " });
        },
      );

      vi.stubGlobal("fetch", fetchMock);

      await expect(
        getASRProvider().transcribe({
          audio: audio(),
          language,
        }),
      ).resolves.toMatchObject({
        success: true,
        provider: "groq",
        model: AUTHORIZED_GROQ_TRANSCRIBE_MODEL,
        language,
        transcript: "Halo DUTA",
      });

      expect(fetchMock).toHaveBeenCalledTimes(1);
      expect(captured?.url).toBe(
        "https://api.groq.com/openai/v1/audio/transcriptions",
      );
      expect(captured?.init.method).toBe("POST");
      expect(captured?.init.headers).toEqual({
        Authorization: "Bearer test-groq-key",
      });
      expect(captured?.init.signal).toBeInstanceOf(AbortSignal);

      const form = captured?.init.body as FormData;

      expect(form.get("model")).toBe(
        AUTHORIZED_GROQ_TRANSCRIBE_MODEL,
      );
      expect(form.get("language")).toBe(language);

      const file = form.get("file") as File;
      expect(file).toBeInstanceOf(File);
      expect(file.type).toBe("audio/webm");
      expect(file.name).toBe("voice-input.webm");
    },
  );

  it("does not call OpenAI when Groq succeeds", async () => {
    enableGroq();
    enableOpenAI();

    const fetchMock = vi.fn(async () =>
      json({ text: "Groq success" }),
    );

    vi.stubGlobal("fetch", fetchMock);

    const result = await getASRProvider().transcribe({
      audio: audio(),
    });

    expect(result).toMatchObject({
      success: true,
      provider: "groq",
      transcript: "Groq success",
    });

    expect(fetchMock).toHaveBeenCalledTimes(1);
  });

  it("falls back exactly once to OpenAI after Groq rate limiting", async () => {
    enableGroq();
    enableOpenAI();

    const fetchMock = vi
      .fn()
      .mockResolvedValueOnce(
        json(
          {
            error: {
              code: "rate_limit_exceeded",
              message: "PRIVATE_GROQ_MESSAGE",
            },
          },
          429,
        ),
      )
      .mockResolvedValueOnce(
        json({ text: "OpenAI fallback success" }),
      );

    vi.stubGlobal("fetch", fetchMock);

    const result = await getASRProvider().transcribe({
      audio: audio(),
      language: "id",
    });

    expect(result).toMatchObject({
      success: true,
      provider: "openai",
      model: AUTHORIZED_OPENAI_TRANSCRIBE_MODEL,
      transcript: "OpenAI fallback success",
    });

    expect(fetchMock).toHaveBeenCalledTimes(2);

    expect(fetchMock.mock.calls[0]?.[0]).toBe(
      "https://api.groq.com/openai/v1/audio/transcriptions",
    );

    expect(fetchMock.mock.calls[1]?.[0]).toBe(
      "https://api.openai.com/v1/audio/transcriptions",
    );
  });

  it("does not fall back to OpenAI for a Groq request failure", async () => {
    enableGroq();
    enableOpenAI();

    const fetchMock = vi.fn(async () =>
      json(
        {
          error: {
            code: "invalid_request",
            message: "PRIVATE_PROVIDER_MESSAGE",
          },
        },
        400,
      ),
    );

    vi.stubGlobal("fetch", fetchMock);

    const result = await getASRProvider().transcribe({
      audio: audio(),
    });

    expect(result).toMatchObject({
      success: false,
      provider: "groq",
      errorCategory: "UNAVAILABLE",
      diagnostics: {
        httpStatus: 400,
        providerErrorCode: "invalid_request",
        normalizedFailureClass: "REQUEST_FAILURE",
      },
    });

    expect(fetchMock).toHaveBeenCalledTimes(1);
  });

  it("uses OpenAI directly when Groq is not configured", async () => {
    enableOpenAI();

    let capturedUrl = "";

    const fetchMock = vi.fn(
      async (url: string) => {
        capturedUrl = url;
        return json({ text: "OpenAI direct" });
      },
    );

    vi.stubGlobal("fetch", fetchMock);

    const result = await getASRProvider().transcribe({
      audio: audio(),
      language: "ms",
    });

    expect(result).toMatchObject({
      success: true,
      provider: "openai",
      model: AUTHORIZED_OPENAI_TRANSCRIBE_MODEL,
      language: "ms",
      transcript: "OpenAI direct",
    });

    expect(fetchMock).toHaveBeenCalledTimes(1);
    expect(capturedUrl).toBe(
      "https://api.openai.com/v1/audio/transcriptions",
    );
  });

  it("preserves safe Groq diagnostics without raw response, credentials, or input names", async () => {
    enableGroq();

    vi.stubGlobal(
      "fetch",
      vi.fn(async () =>
        json(
          {
            error: {
              code: "invalid_api_key",
              message: "PRIVATE_PROVIDER_MESSAGE",
            },
            secret: "test-groq-key",
          },
          401,
        ),
      ),
    );

    const result = await getASRProvider().transcribe({
      audio: audio(),
    });

    const serialized = JSON.stringify(result);

    expect(result).toMatchObject({
      success: false,
      provider: "groq",
      errorCategory: "UNAVAILABLE",
      diagnostics: {
        httpStatus: 401,
        providerErrorCode: "invalid_api_key",
        normalizedFailureClass: "AUTHENTICATION_FAILURE",
        requestAttempted: true,
        providerResponded: true,
      },
    });

    expect(serialized).not.toContain("PRIVATE_PROVIDER_MESSAGE");
    expect(serialized).not.toContain("test-groq-key");
    expect(serialized).not.toContain("founder-recording-name");
  });

  it("falls back to OpenAI after a Groq timeout", async () => {
    enableGroq();
    enableOpenAI();

    const fetchMock = vi
      .fn()
      .mockRejectedValueOnce(
        new DOMException("Aborted", "AbortError"),
      )
      .mockResolvedValueOnce(
        json({ text: "Recovered after timeout" }),
      );

    vi.stubGlobal("fetch", fetchMock);

    const result = await getASRProvider().transcribe({
      audio: audio(),
    });

    expect(result).toMatchObject({
      success: true,
      provider: "openai",
      transcript: "Recovered after timeout",
    });

    expect(fetchMock).toHaveBeenCalledTimes(2);
  });

  it("preserves the 15 second timeout contract", () => {
    expect(ASR_TIMEOUT_MS).toBe(15_000);
  });
});
