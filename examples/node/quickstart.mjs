#!/usr/bin/env node
/**
 * End-to-end test-mode flow (fictional state ZZ).
 * Untested in this kit: requires EVICTIONS_API_KEY=eak_test_...
 * Node 18+ (global fetch). Run: node examples/node/quickstart.mjs
 */
import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { randomUUID } from 'node:crypto';

const key = process.env.EVICTIONS_API_KEY;
if (!key) {
  console.error('Set EVICTIONS_API_KEY to a test key (eak_test_...)');
  process.exit(1);
}
const base = process.env.EVICTIONS_API_URL || 'https://api.evictionsapi.com';
const root = join(dirname(fileURLToPath(import.meta.url)), '..', '..');
const pdf = readFileSync(join(root, 'examples/fixtures/authority-sample.pdf'));

async function api(method, path, body) {
  const headers = {
    Authorization: `Bearer ${key}`,
    Accept: 'application/json',
  };
  if (body !== undefined) {
    headers['Content-Type'] = 'application/json';
    if (method === 'POST' && path === '/v1/cases') {
      headers['Idempotency-Key'] = randomUUID();
    }
  }
  const res = await fetch(`${base}${path}`, {
    method,
    headers,
    body: body !== undefined ? JSON.stringify(body) : undefined,
  });
  const text = await res.text();
  let data;
  try {
    data = text ? JSON.parse(text) : null;
  } catch {
    data = text;
  }
  if (!res.ok) {
    const err = new Error(`${method} ${path} -> ${res.status}`);
    err.data = data;
    throw err;
  }
  return data;
}

const resolved = await api('GET', '/v1/jurisdictions/resolve?state=ZZ');
console.log('resolve ZZ served=', resolved.served, 'handling=', resolved.handling);

const created = await api('POST', '/v1/cases', {
  ground: 'nonpayment',
  entryPoint: 'notice',
  property: {
    line1: '1 Main St',
    city: 'Testville',
    state: 'ZZ',
    zip: '00000',
    ownerOfRecord: 'Pat Landlord',
  },
  parties: [
    { role: 'plaintiff', name: 'Pat Landlord' },
    { role: 'defendant', name: 'Terry Tenant' },
  ],
  lease: { startDate: '2025-01-01', monthlyRentCents: 150000 },
  ledger: [
    { date: '2026-09-01', type: 'charge', amountCents: 150000 },
    { date: '2026-10-01', type: 'charge', amountCents: 150000 },
    { date: '2026-10-02', type: 'payment', amountCents: 50000 },
  ],
  amountOwedCents: 250000,
  attestations: {
    authority: true,
    notRetaliatory: true,
    notDiscriminatory: true,
    servicemember: 'no',
    caresCovered: false,
  },
});
console.log('created', created.id, created.state);

await api('POST', `/v1/cases/${created.id}/documents`, {
  filename: 'deed.pdf',
  purpose: 'authority',
  contentBase64: pdf.toString('base64'),
});
console.log('authority uploaded');

const validation = await api('POST', `/v1/cases/${created.id}/validate`);
console.log('validate ok=', validation.ok ?? validation);

const submitted = await api('POST', `/v1/cases/${created.id}/submit`);
console.log('submitted', submitted.state, submitted.nextAction);

let state = submitted.state;
for (let i = 0; i < 40; i++) {
  const advanced = await api('POST', `/v1/cases/${created.id}/advance`).catch((e) => e.data);
  state = advanced?.state || advanced?.error?.code || state;
  console.log(`advance ${i + 1} ->`, state);
  if (state === 'closed') break;
  await new Promise((r) => setTimeout(r, 300));
}

const finalCase = await api('GET', `/v1/cases/${created.id}`);
console.log('final', finalCase.id, finalCase.state, finalCase.nextAction);
