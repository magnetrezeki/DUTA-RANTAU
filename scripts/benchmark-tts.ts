import { toSpeakableResponse } from "../lib/speakable-response";
const categories = ["indonesian_short", "malay_short", "malaysian_place_names", "kbri_kjri_terms", "job_vocabulary", "mixed_language", "numbers_dates", "provider_failure"];
console.log(JSON.stringify({ manualOnly: true, categories, provider: "DEFERRED_PROVIDER_VALIDATION", preview: toSpeakableResponse("Respons benchmark tersedia di layar.") }, null, 2));
