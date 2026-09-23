import "server-only";

import { createHash } from "node:crypto";
import { canonicalizeOfficialUrl, malaysiaOfficialSources, type MalaysiaOfficialSource } from "@/lib/official-source-registry";

export type OfficialStoryCandidate = {
  sourceId: string;
  externalId?: string;
  canonicalUrl?: string;
  title: string;
  body: string;
  publishedAt: string;
  mediaFingerprint?: string;
};

export type StorySourceReference = {
  sourceId: string;
  channel: MalaysiaOfficialSource["channel"];
  url?: string;
  externalId?: string;
  firstSeenAt: string;
};

export type CanonicalOfficialStory = {
  id: string;
  institution: string;
  title: string;
  body: string;
  publishedAt: string;
  firstSeenAt: string;
  canonicalSourceId: string;
  canonicalUrl?: string;
  contentFingerprint: string;
  mediaFingerprint?: string;
  sourceReferences: StorySourceReference[];
};

export interface OfficialSourceAdapter {
  readonly sourceId: string;
  readonly available: boolean;
  readonly dependency: string;
  collect(): Promise<readonly OfficialStoryCandidate[]>;
}

export class UnavailableOfficialSourceAdapter implements OfficialSourceAdapter {
  readonly available = false;
  constructor(readonly sourceId: string, readonly dependency: string) {}
  async collect(): Promise<readonly OfficialStoryCandidate[]> { return []; }
}

const sources = new Map<string, MalaysiaOfficialSource>(malaysiaOfficialSources.map(item => [item.id, item]));
const normalizeText = (value: string) => value.normalize("NFKC").toLowerCase().replace(/[^\p{L}\p{N}]+/gu, " ").trim();
const digest = (value: string) => createHash("sha256").update(value).digest("hex");
const hoursApart = (left: string, right: string) => Math.abs(Date.parse(left) - Date.parse(right)) / 3_600_000;
const sourceRank = (source: MalaysiaOfficialSource) => source.channel === "WEBSITE" ? 3 : source.domain === "MISSION" ? 2 : 1;

function normalizeCandidate(candidate: OfficialStoryCandidate) {
  const source = sources.get(candidate.sourceId);
  if (!source || !source.infoRantauEligible) throw new Error("UNAPPROVED_OFFICIAL_SOURCE");
  const title = candidate.title.trim(); const body = candidate.body.trim();
  if (!title || !body || Number.isNaN(Date.parse(candidate.publishedAt))) throw new Error("INVALID_OFFICIAL_STORY");
  const canonicalUrl = candidate.canonicalUrl ? canonicalizeOfficialUrl(candidate.canonicalUrl) : undefined;
  return { candidate: { ...candidate, title, body, canonicalUrl }, source, normalizedTitle: normalizeText(title), contentFingerprint: digest(normalizeText(body)) };
}

function matches(story: CanonicalOfficialStory, next: ReturnType<typeof normalizeCandidate>): boolean {
  if (story.institution !== next.source.institution) return false;
  if (story.canonicalUrl && next.candidate.canonicalUrl && story.canonicalUrl === next.candidate.canonicalUrl) return true;
  if (story.mediaFingerprint && next.candidate.mediaFingerprint && story.mediaFingerprint === next.candidate.mediaFingerprint && hoursApart(story.publishedAt, next.candidate.publishedAt) <= 168) return true;
  const sameTitle = normalizeText(story.title) === next.normalizedTitle;
  return sameTitle && hoursApart(story.publishedAt, next.candidate.publishedAt) <= 72;
}

export function ingestOfficialStories(existing: readonly CanonicalOfficialStory[], candidates: readonly OfficialStoryCandidate[], seenAt: string): CanonicalOfficialStory[] {
  const stories = existing.map(story => ({ ...story, sourceReferences: [...story.sourceReferences] }));
  for (const raw of candidates) {
    const next = normalizeCandidate(raw);
    let story = stories.find(item => matches(item, next));
    const reference: StorySourceReference = { sourceId: next.source.id, channel: next.source.channel, ...(next.candidate.canonicalUrl ? { url: next.candidate.canonicalUrl } : {}), ...(next.candidate.externalId ? { externalId: next.candidate.externalId } : {}), firstSeenAt: seenAt };
    if (!story) {
      stories.push({ id: digest(`${next.source.institution}|${next.normalizedTitle}|${next.candidate.publishedAt}`).slice(0, 24), institution: next.source.institution, title: next.candidate.title, body: next.candidate.body, publishedAt: next.candidate.publishedAt, firstSeenAt: seenAt, canonicalSourceId: next.source.id, ...(next.candidate.canonicalUrl ? { canonicalUrl: next.candidate.canonicalUrl } : {}), contentFingerprint: next.contentFingerprint, ...(next.candidate.mediaFingerprint ? { mediaFingerprint: next.candidate.mediaFingerprint } : {}), sourceReferences: [reference] });
      continue;
    }
    const duplicateReference = story.sourceReferences.some(item => item.sourceId === reference.sourceId && ((item.externalId && item.externalId === reference.externalId) || (item.url && item.url === reference.url)));
    if (!duplicateReference) story.sourceReferences.push(reference);
    const currentSource = sources.get(story.canonicalSourceId);
    if (currentSource && sourceRank(next.source) > sourceRank(currentSource)) {
      story.title = next.candidate.title; story.body = next.candidate.body; story.publishedAt = next.candidate.publishedAt; story.canonicalSourceId = next.source.id; story.canonicalUrl = next.candidate.canonicalUrl; story.contentFingerprint = next.contentFingerprint;
    }
  }
  return stories;
}

export function adapterFor(source: MalaysiaOfficialSource): OfficialSourceAdapter {
  const dependency = source.channel === "WEBSITE" ? "Approved RSS/feed, publisher API, or controlled collector" : `Approved ${source.channel} API/webhook and credential`;
  return new UnavailableOfficialSourceAdapter(source.id, dependency);
}
