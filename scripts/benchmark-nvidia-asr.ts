import { readFile } from "node:fs/promises";
import { getASRProvider } from "../lib/services/asr-provider";

const categories = ["indonesian_clear", "malay_clear", "mixed_language", "malaysian_place_names", "kbri_kjri_terms", "migrant_worker_vocabulary", "noisy_environment", "short_question"] as const;
async function main() {
  const filePath = process.argv[3]; const category = process.argv[2];
  if (!process.argv.includes("--live") || !filePath || !categories.includes(category as typeof categories[number])) { console.error(`Manual only: tsx scripts/benchmark-nvidia-asr.ts <category> <audio-file> --live\\nCategories: ${categories.join(", ")}`); process.exitCode = 1; return; }
  const bytes = await readFile(filePath); const audio = new File([bytes], "benchmark.webm", { type: "audio/webm" }); const result = await getASRProvider().transcribe({ audio, language: category === "malay_clear" ? "ms" : "id" });
  console.log(JSON.stringify({ category, provider: result.provider, model: result.model ?? null, language: result.language ?? null, latencyMs: result.latencyMs, success: result.success, fallback: !result.success, obviousTranscriptionError: null, errorCategory: result.errorCategory ?? null }, null, 2));
}
void main();
