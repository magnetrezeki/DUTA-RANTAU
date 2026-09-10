export function toSpeakableResponse(text: string, language: "id" | "ms" = "id") {
  const withoutUrls = text.replace(/https?:\/\/\S+/gi, "detail sumber tersedia di layar");
  const compact = withoutUrls.replace(/\s+/g, " ").trim().slice(0, 500);
  if (!compact) return language === "ms" ? "Jawapan belum tersedia di skrin." : "Jawaban belum tersedia di layar.";
  return compact;
}
