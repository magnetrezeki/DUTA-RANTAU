import { describe, expect, it } from 'vitest';
import { existsSync, readFileSync } from 'node:fs';

const documents = [
  'R2A02_PRIVACY_NOTICE_FRAMEWORK.md',
  'R2A02_DATA_PROCESSING_INVENTORY.md',
  'R2A02_VENDOR_PROCESSOR_REGISTER.md',
  'R2A02_CROSS_BORDER_PROCESSING_REGISTER.md',
  'R2A02_DPO_REQUIREMENT_ASSESSMENT.md',
  'R2A02_DPIA_FRAMEWORK.md',
] as const;

const read = (name: string) => readFileSync(`docs/duta-v2.5/${name}`, 'utf8');

describe('R2A-02A governance foundation', () => {
  it('creates the six governed source-of-truth artifacts', () => {
    for (const document of documents) {
      expect(existsSync(`docs/duta-v2.5/${document}`)).toBe(true);
      expect(read(document)).toContain('DOCUMENT OWNER');
      expect(read(document)).toContain('ACCOUNTABLE OWNER');
      expect(read(document)).toContain('NO_SECRET_CONTENT');
    }
  });

  it('keeps privacy disclosures as a framework with unresolved request, export, and retention facts', () => {
    const privacy = read('R2A02_PRIVACY_NOTICE_FRAMEWORK.md');
    expect(privacy).toContain('Framework only; not a final legal privacy notice.');
    expect(privacy).toContain('PRIVACY_REQUEST_CHANNEL:** `TO_VERIFY`');
    expect(privacy).toContain('DATA_EXPORT_WORKFLOW:** `NOT_IMPLEMENTED`');
    expect(privacy).toContain('RETENTION_PERIODS:** `TO_VERIFY`');
  });

  it('records inventory, vendor, transfer, DPO, and DPIA facts without invented conclusions', () => {
    expect(read('R2A02_DATA_PROCESSING_INVENTORY.md')).toContain('PROC-017');
    expect(read('R2A02_VENDOR_PROCESSOR_REGISTER.md')).toContain('CONFIGURED_RUNTIME_INTEGRATION');
    expect(read('R2A02_VENDOR_PROCESSOR_REGISTER.md')).toContain('OPTIONAL');
    const transfers = read('R2A02_CROSS_BORDER_PROCESSING_REGISTER.md');
    expect(transfers).toContain('NONE CONCLUSIVELY ESTABLISHED');
    expect(transfers).toContain('TRANSFER STATUS: TO_VERIFY');
    expect(read('R2A02_DPO_REQUIREMENT_ASSESSMENT.md')).toContain('DPO_REQUIREMENT_STATUS:** `LEGAL_REVIEW_REQUIRED`');
    const dpia = read('R2A02_DPIA_FRAMEWORK.md');
    for (const feature of ['AI', 'Voice', 'Verification', 'Citizen Report / moderation evidence', 'Precise location', 'Career Passport', 'Job matching', 'Health', 'CCTV', 'MyDigital ID', 'Cross-border processing']) expect(dpia).toContain(feature);
  });

  it('preserves the locked launch and consular referral boundaries', () => {
    const privacy = read('R2A02_PRIVACY_NOTICE_FRAMEWORK.md');
    for (const boundary of ['Consumer subscription or paywall | `REPOSITORY_FACT: ABSENT`', 'DUTA Kerja | `FOUNDER_POLICY: DISCOVERY_ONLY`', 'Pasar Rantau | `REPOSITORY_FACT: WITHHELD`', 'Payment execution | `FOUNDER_POLICY: DISABLED`', 'Health, E-Undi, CCTV, MyDigital ID, multi-country expansion | `DEFERRED`']) expect(privacy).toContain(boundary);
    for (const deniedAction of ['does not initially book appointments', 'reserve slots', 'collect passport data', 'store appointment credentials', 'proxy-submit consular applications']) expect(privacy).toContain(deniedAction);
    expect(privacy).toContain('not a final legal privacy notice');
    expect(privacy).not.toMatch(/official duta partner|authorized by kbri|kbri verified duta/i);
  });

  it('contains no secret-like configuration values', () => {
    for (const document of documents) {
      expect(read(document)).not.toMatch(/(?:sk|pk|AIza)[A-Za-z0-9_-]{16,}/);
      expect(read(document)).not.toMatch(/postgres(?:ql)?:\/\/[^\s]+@/i);
      expect(read(document)).not.toMatch(/-----BEGIN (?:RSA |EC )?PRIVATE KEY-----/);
    }
  });
});
