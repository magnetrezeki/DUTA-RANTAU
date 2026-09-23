import "server-only";

export type ASRErrorCategory = "UNAVAILABLE" | "TIMEOUT" | "INVALID_RESPONSE";
export type ASRFailureClass =
  | "AUTHENTICATION_FAILURE"
  | "PERMISSION_FAILURE"
  | "REQUEST_FAILURE"
  | "RATE_LIMIT_FAILURE"
  | "PROVIDER_FAILURE"
  | "TIMEOUT_FAILURE"
  | "NETWORK_FAILURE"
  | "RESPONSE_FAILURE";

export type ASRDiagnostics = {
  httpStatus?: number;
  providerErrorCode?: string;
  normalizedFailureClass?: ASRFailureClass;
  requestAttempted: boolean;
  requestLeftApplication: boolean | null;
  providerResponded: boolean;
};

export type ASRProviderName = "fallback" | "groq" | "openai";

export type ASRDiagnosticStage = {
  provider: "groq" | "openai";
  diagnostics?: ASRDiagnostics;
};

export type ASRResult = {
  success: boolean;
  provider: ASRProviderName;
  transcript?: string;
  model?: string;
  language?: string;
  latencyMs: number;
  errorCategory?: ASRErrorCategory;
  diagnostics?: ASRDiagnostics;
  diagnosticChain?: ASRDiagnosticStage[];
};

export type ASRInput = {
  audio: File;
  language?: "id" | "ms";
};

export interface ASRProvider {
  transcribe(input: ASRInput): Promise<ASRResult>;
}

export const ASR_TIMEOUT_MS = 15_000;

export const AUTHORIZED_GROQ_TRANSCRIBE_MODEL = "whisper-large-v3-turbo";
export const AUTHORIZED_OPENAI_TRANSCRIBE_MODEL = "gpt-4o-mini-transcribe";

const GROQ_TRANSCRIPTIONS_URL =
  "https://api.groq.com/openai/v1/audio/transcriptions";

const OPENAI_TRANSCRIPTIONS_URL =
  "https://api.openai.com/v1/audio/transcriptions";

const diagnostics = (
  values: Partial<ASRDiagnostics> = {},
): ASRDiagnostics => ({
  requestAttempted: false,
  requestLeftApplication: false,
  providerResponded: false,
  ...values,
});

const fallback = (
  errorCategory: ASRErrorCategory,
  latencyMs = 0,
  detail = diagnostics(),
): ASRResult => ({
  success: false,
  provider: "fallback",
  latencyMs,
  errorCategory,
  diagnostics: detail,
});

function failureClass(status: number): ASRFailureClass {
  if (status === 401) return "AUTHENTICATION_FAILURE";
  if (status === 403) return "PERMISSION_FAILURE";
  if (status === 400 || status === 404 || status === 422)
    return "REQUEST_FAILURE";
  if (status === 429) return "RATE_LIMIT_FAILURE";
  return "PROVIDER_FAILURE";
}

function safeErrorCode(payload: unknown): string | undefined {
  if (
    typeof payload !== "object" ||
    payload === null ||
    !("error" in payload) ||
    typeof payload.error !== "object" ||
    payload.error === null ||
    !("code" in payload.error)
  ) {
    return undefined;
  }

  const code = (payload.error as { code?: unknown }).code;

  return typeof code === "string" &&
    /^[A-Za-z0-9_.-]{1,80}$/.test(code)
    ? code
    : undefined;
}

function providerFilename(audio: File) {
  const type = audio.type.toLowerCase().split(";", 1)[0];

  const extension: Record<string, string> = {
    "audio/webm": "webm",
    "audio/mp4": "mp4",
    "audio/mpeg": "mp3",
    "audio/wav": "wav",
    "audio/ogg": "ogg",
  };

  return `voice-input.${extension[type] ?? "webm"}`;
}

function configuredProvider(
  provider: "groq" | "openai",
  apiKey: string | undefined,
  model: string | undefined,
  authorizedModel: string,
  url: string,
): ASRProvider | null {
  if (!apiKey?.trim() || model !== authorizedModel) return null;

  return {
    async transcribe({ audio, language = "id" }) {
      const startedAt = Date.now();
      const controller = new AbortController();
      const timeout = setTimeout(
        () => controller.abort(),
        ASR_TIMEOUT_MS,
      );

      try {
        const form = new FormData();

        form.set("file", audio, providerFilename(audio));
        form.set("model", model);
        form.set("language", language);

        const response = await fetch(url, {
          method: "POST",
          headers: {
            Authorization: `Bearer ${apiKey}`,
          },
          body: form,
          signal: controller.signal,
        });

        if (!response.ok) {
          let providerErrorCode: string | undefined;

          try {
            providerErrorCode = safeErrorCode(await response.json());
          } catch {
            // Raw provider response is intentionally discarded.
          }

          return {
            success: false,
            provider,
            latencyMs: Date.now() - startedAt,
            errorCategory: "UNAVAILABLE",
            diagnostics: diagnostics({
              httpStatus: response.status,
              providerErrorCode,
              normalizedFailureClass: failureClass(response.status),
              requestAttempted: true,
              requestLeftApplication: true,
              providerResponded: true,
            }),
          };
        }

        let body: unknown;

        try {
          body = await response.json();
        } catch {
          return {
            success: false,
            provider,
            latencyMs: Date.now() - startedAt,
            errorCategory: "INVALID_RESPONSE",
            diagnostics: diagnostics({
              httpStatus: response.status,
              normalizedFailureClass: "RESPONSE_FAILURE",
              requestAttempted: true,
              requestLeftApplication: true,
              providerResponded: true,
            }),
          };
        }

        const transcript =
          typeof body === "object" &&
          body !== null &&
          "text" in body &&
          typeof body.text === "string"
            ? body.text.trim()
            : "";

        if (!transcript) {
          return {
            success: false,
            provider,
            latencyMs: Date.now() - startedAt,
            errorCategory: "INVALID_RESPONSE",
            diagnostics: diagnostics({
              httpStatus: response.status,
              normalizedFailureClass: "RESPONSE_FAILURE",
              requestAttempted: true,
              requestLeftApplication: true,
              providerResponded: true,
            }),
          };
        }

        return {
          success: true,
          provider,
          model,
          language,
          transcript,
          latencyMs: Date.now() - startedAt,
          diagnostics: diagnostics({
            httpStatus: response.status,
            requestAttempted: true,
            requestLeftApplication: true,
            providerResponded: true,
          }),
        };
      } catch (error) {
        const timedOut =
          error instanceof DOMException &&
          error.name === "AbortError";

        return {
          success: false,
          provider,
          latencyMs: Date.now() - startedAt,
          errorCategory: timedOut ? "TIMEOUT" : "UNAVAILABLE",
          diagnostics: diagnostics({
            normalizedFailureClass: timedOut
              ? "TIMEOUT_FAILURE"
              : "NETWORK_FAILURE",
            requestAttempted: true,
            requestLeftApplication: null,
            providerResponded: false,
          }),
        };
      } finally {
        clearTimeout(timeout);
      }
    },
  };
}

function eligibleForFallback(result: ASRResult): boolean {
  if (result.success) return false;

  const failureClass = result.diagnostics?.normalizedFailureClass;

  return (
    failureClass === "AUTHENTICATION_FAILURE" ||
    failureClass === "PERMISSION_FAILURE" ||
    failureClass === "RATE_LIMIT_FAILURE" ||
    failureClass === "PROVIDER_FAILURE" ||
    failureClass === "TIMEOUT_FAILURE" ||
    failureClass === "NETWORK_FAILURE" ||
    failureClass === "RESPONSE_FAILURE"
  );
}

export function getASRProvider(): ASRProvider {
  const groq = configuredProvider(
    "groq",
    process.env.GROQ_API_KEY,
    process.env.GROQ_TRANSCRIBE_MODEL,
    AUTHORIZED_GROQ_TRANSCRIBE_MODEL,
    GROQ_TRANSCRIPTIONS_URL,
  );

  const openai = configuredProvider(
    "openai",
    process.env.OPENAI_API_KEY,
    process.env.OPENAI_TRANSCRIBE_MODEL,
    AUTHORIZED_OPENAI_TRANSCRIBE_MODEL,
    OPENAI_TRANSCRIPTIONS_URL,
  );

  return {
    async transcribe(input) {
     if (groq) {
  const groqResult = await groq.transcribe(input);

  if (groqResult.success) return groqResult;

  if (!eligibleForFallback(groqResult)) return groqResult;

  if (openai) {
    const openaiResult = await openai.transcribe(input);

    if (!openaiResult.success) {
      return {
        ...openaiResult,
        diagnosticChain: [
          {
            provider: "groq",
            diagnostics: groqResult.diagnostics,
          },
          {
            provider: "openai",
            diagnostics: openaiResult.diagnostics,
          },
        ],
      };
    }

    return openaiResult;
  }

  // Preserve the primary provider's safe diagnostics when
  // no secondary provider is configured.
  return groqResult;
}

if (openai) {
  return openai.transcribe(input);
}

return fallback("UNAVAILABLE");
    },
  };
}
