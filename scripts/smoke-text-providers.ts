import { runTextProviderSmoke, type TextProviderName } from '../lib/services/ai-provider-smoke';

const allowed = ['gemini', 'groq', 'openai'] as const;

async function main() {
  if (!process.argv.includes('--live')) {
    console.error('Manual only: use --live and select gemini, groq, openai, or all.');
    process.exitCode = 1;
    return;
  }
  const selection = process.argv.find(value => value === 'all' || allowed.includes(value as TextProviderName));
  if (!selection) {
    console.error('Select exactly one provider or all: gemini | groq | openai | all');
    process.exitCode = 1;
    return;
  }
  const providers: readonly TextProviderName[] = selection === 'all' ? allowed : [selection as TextProviderName];
  const results = [];
  for (const provider of providers) results.push(await runTextProviderSmoke(provider));
  console.log(JSON.stringify(results, null, 2));
  if (results.some(result => result.result !== 'PASS')) process.exitCode = 2;
}

void main();
