


import { appDb } from '../db/client';
import { officialSources as table } from '../db/schema';
import { officialSources } from '../lib/demo-data';

async function main() {
if (!appDb) {
throw new Error('DATABASE_URL is required');
}

for (const source of officialSources) {
await appDb
.insert(table)
.values({
institution: source.institution,
channel: source.channel,
url: source.url,
category: source.category,
priority: source.priority,
trustLevel: 'OFFICIAL_VERIFIED',
lastChecked: new Date(source.lastChecked + 'T00:00:00Z'),
active: true,
})
.onConflictDoUpdate({
target: table.url,
set: {
institution: source.institution,
channel: source.channel,
category: source.category,
priority: source.priority,
lastChecked: new Date(source.lastChecked + 'T00:00:00Z'),
active: true,
updatedAt: new Date(),
},
});
}

console.log(`Imported ${officialSources.length} verified official channels.`);
}

main()
.then(() => process.exit(0))
.catch((error) => {
console.error(error);
process.exit(1);
});
