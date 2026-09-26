import { z } from "zod";

export const fiveWState = z.enum(["SUPPORTED", "NOT_STATED", "NOT_MATERIAL"]);
const supported = z.object({ state: z.literal("SUPPORTED"), text: z.string().trim().min(1).max(500) });
const absent = z.object({ state: z.enum(["NOT_STATED", "NOT_MATERIAL"]) }).strict();
export const fiveWField = z.union([supported, absent]);
export const fiveWContext = z.object({
  version: z.literal(1), who: fiveWField, where: fiveWField,
  when: z.union([supported.extend({ startsAt: z.string().datetime({ offset: true }).optional(), endsAt: z.string().datetime({ offset: true }).optional() }), absent]),
  why: fiveWField,
}).strict();
export type FiveWContext = z.infer<typeof fiveWContext>;
export type NewsRisk = "ROUTINE" | "HIGH_RISK";
export type NewsReviewState = "DRAFT" | "VERIFIED_BY_EDITOR" | "READY_FOR_REVIEW" | "APPROVED" | "CHANGES_REQUESTED" | "REJECTED";
export type NewsPublicationState = "DRAFT" | "PUBLISHED" | "WITHDRAWN" | "SUPERSEDED";
export type NewsCorrectionState = "CURRENT" | "CORRECTED" | "WITHDRAWN" | "SUPERSEDED";
export type NewsStoryState = { risk: NewsRisk; reviewState: NewsReviewState; publicationState: NewsPublicationState; correctionState: NewsCorrectionState; approvedBy?: string | null };
export type NewsActor = { id: string; role: "EDITOR" | "MODERATOR" | "SUPER_ADMIN" };
export type NewsTransition = "VERIFY" | "SUBMIT" | "APPROVE" | "PUBLISH" | "WITHDRAW" | "SUPERSEDE";

export const isPubliclyVisibleNews = (story: Pick<NewsStoryState, "publicationState" | "correctionState">) => story.publicationState === "PUBLISHED" && story.correctionState === "CURRENT";

export function assertNewsTransition(story: NewsStoryState, actor: NewsActor, transition: NewsTransition): void {
  const editor = actor.role === "EDITOR"; const moderator = actor.role === "MODERATOR" || actor.role === "SUPER_ADMIN";
  if (transition === "VERIFY" && editor && story.risk === "ROUTINE" && story.reviewState === "DRAFT") return;
  if (transition === "SUBMIT" && editor && story.risk === "HIGH_RISK" && ["DRAFT", "CHANGES_REQUESTED"].includes(story.reviewState)) return;
  if (transition === "APPROVE" && moderator && story.risk === "HIGH_RISK" && story.reviewState === "READY_FOR_REVIEW") return;
  if (transition === "PUBLISH" && (editor || moderator) && story.publicationState === "DRAFT" && ((story.risk === "ROUTINE" && story.reviewState === "VERIFIED_BY_EDITOR") || (story.risk === "HIGH_RISK" && story.reviewState === "APPROVED" && !!story.approvedBy))) return;
  if (["WITHDRAW", "SUPERSEDE"].includes(transition) && moderator && story.publicationState === "PUBLISHED") return;
  throw new Error("NEWS_TRANSITION_FORBIDDEN");
}

const platformHosts: Record<string, readonly string[]> = { INSTAGRAM: ["instagram.com"], FACEBOOK: ["facebook.com"], X: ["x.com"], YOUTUBE: ["youtube.com", "youtu.be"], WEBSITE: [] };
export function validateManualOfficialNewsUrl(value: string, channel: string, sourceUrl: string): string {
  if (value.length > 2048) throw new Error("NEWS_URL_TOO_LONG");
  let url: URL; try { url = new URL(value); } catch { throw new Error("NEWS_URL_INVALID"); }
  const host = url.hostname.toLowerCase();
  if (url.protocol !== "https:" || url.username || url.password || host === "localhost" || /^(127\.|10\.|0\.|169\.254\.|192\.168\.|172\.(1[6-9]|2\d|3[01])\.)/.test(host) || host === "::1") throw new Error("NEWS_URL_UNSAFE");
  const allowed = platformHosts[channel] ?? []; const sourceHost = new URL(sourceUrl).hostname.toLowerCase();
  if (!(allowed.length ? allowed.some(domain => host === domain || host.endsWith(`.${domain}`)) : host === sourceHost || host.endsWith(`.${sourceHost}`))) throw new Error("NEWS_URL_SOURCE_MISMATCH");
  url.hostname = host; url.hash = ""; if (url.pathname !== "/") url.pathname = url.pathname.replace(/\/+$/, ""); return url.toString();
}
