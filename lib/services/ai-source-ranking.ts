export type SourceTier = 'TIER_1' | 'TIER_2' | 'TIER_3' | 'TIER_4';
export type SourceRequirement = 'NONE' | 'TRUSTED' | 'OFFICIAL_REQUIRED';
export type RankedSource = { id: string; label: string; tier: SourceTier; official?: boolean; verifiedPartner?: boolean; sponsored?: boolean };

const order: Record<SourceTier, number> = { TIER_1: 1, TIER_2: 2, TIER_3: 3, TIER_4: 4 };

export function classifySourceTier(source: Omit<RankedSource, 'tier'> & { kind?: 'official' | 'duta_internal' | 'partner' | 'community' | 'model' }): SourceTier {
  if (source.kind === 'official' || source.kind === 'duta_internal') return 'TIER_1';
  if (source.kind === 'partner' || source.verifiedPartner) return 'TIER_2';
  if (source.kind === 'community') return 'TIER_3';
  return 'TIER_4';
}

export function rankSources(sources: RankedSource[], requirement: SourceRequirement) {
  const ranked = [...sources].sort((a, b) => order[a.tier] - order[b.tier]);
  if (requirement === 'OFFICIAL_REQUIRED') {
    const official = ranked.filter((source) => source.tier === 'TIER_1');
    return official.length ? { status: 'ok' as const, sources: official } : { status: 'AUTHORITATIVE_SOURCE_REQUIRED' as const, sources: [] };
  }
  if (requirement === 'TRUSTED') return { status: 'ok' as const, sources: ranked.filter((source) => source.tier === 'TIER_1' || source.tier === 'TIER_2') };
  return { status: 'ok' as const, sources: ranked };
}
