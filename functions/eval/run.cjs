#!/usr/bin/env node
/**
 * Bolo accuracy evaluation.
 *
 *   npm run build
 *   node eval/run.cjs --mock        # free: tests the harness with the rule-based mock
 *   node eval/run.cjs               # REAL Claude calls (costs ~US$0.0003 per case)
 *   node eval/run.cjs --only rem-   # run cases whose id starts with "rem-"
 *
 * Needs ANTHROPIC_API_KEY in the environment for real runs. Writes a report to
 * eval/results/<timestamp>.json. Change the prompt ONLY if the score goes up.
 */
const fs = require("node:fs");
const path = require("node:path");

const { callModel, MODEL } = require("../lib/parse/ai");
const { buildCalendar } = require("../lib/parse/calendar");
const { mockParse } = require("../lib/parse/mock");
const { sanitize, unknownResponse } = require("../lib/parse/validate");

const args = process.argv.slice(2);
const useMock = args.includes("--mock");
const onlyIdx = args.indexOf("--only");
const only = onlyIdx >= 0 ? args[onlyIdx + 1] : null;

const golden = JSON.parse(fs.readFileSync(path.join(__dirname, "golden.json"), "utf8"));
const now = new Date(golden.now);
const cal = buildCalendar(now);
const cases = golden.cases.filter((c) => !only || c.id.startsWith(only));

const norm = (v) => (typeof v === "string" ? v.trim().toLowerCase() : v);

function check(field, expected, actual) {
  const options = Array.isArray(expected) ? expected : [expected];
  if (field === "person") {
    // Names: correct if the expected name appears in what the model returned.
    return options.some((o) => (o === null ? actual === null : actual != null && norm(actual).includes(norm(o))));
  }
  return options.some((o) => norm(o) === norm(actual));
}

async function runCase(client, c) {
  const started = Date.now();
  let response;
  let usage = { inputTokens: 0, outputTokens: 0 };
  let stopReason = "mock";
  if (useMock) {
    response = sanitize(mockParse(c.text, cal), now);
  } else {
    const result = await callModel(client, c.text, cal, /[ঀ-৿]/.test(c.text) ? "bn" : "en");
    response = result.output ? sanitize(result.output, now, c.text) : unknownResponse();
    usage = { inputTokens: result.inputTokens, outputTokens: result.outputTokens };
    stopReason = result.stopReason;
  }
  const fields = {};
  for (const [field, expected] of Object.entries(c.expect)) {
    fields[field] = { expected, actual: response[field], ok: check(field, expected, response[field]) };
  }
  return { id: c.id, text: c.text, ok: Object.values(fields).every((f) => f.ok), fields, usage, stopReason, ms: Date.now() - started };
}

async function main() {
  let client = null;
  if (!useMock) {
    const Anthropic = require("@anthropic-ai/sdk").default;
    client = new Anthropic({ maxRetries: 2 });
  }
  const results = [];
  const concurrency = 4;
  for (let i = 0; i < cases.length; i += concurrency) {
    const batch = await Promise.all(
      cases.slice(i, i + concurrency).map((c) =>
        runCase(client, c).catch((e) => ({ id: c.id, text: c.text, ok: false, error: String(e), fields: {}, usage: { inputTokens: 0, outputTokens: 0 } })),
      ),
    );
    results.push(...batch);
  }

  // Per-field accuracy.
  const perField = {};
  for (const r of results) {
    for (const [f, v] of Object.entries(r.fields)) {
      perField[f] ??= { ok: 0, total: 0 };
      perField[f].total++;
      if (v.ok) perField[f].ok++;
    }
  }
  const passed = results.filter((r) => r.ok).length;
  const inTok = results.reduce((s, r) => s + r.usage.inputTokens, 0);
  const outTok = results.reduce((s, r) => s + r.usage.outputTokens, 0);
  // Claude Haiku 5.5 list price: $0.10 / 1M input, $0.50 / 1M output (re-check pricing page).
  const cost = (inTok * 0.1 + outTok * 0.5) / 1e6;

  console.log(`\nBolo eval: ${useMock ? "MOCK" : MODEL}, ${cases.length} cases`);
  console.log("─".repeat(60));
  for (const r of results) {
    if (r.ok) continue;
    console.log(`✗ ${r.id}: "${r.text}"`);
    if (r.error) console.log(`    error: ${r.error}`);
    for (const [f, v] of Object.entries(r.fields)) {
      if (!v.ok) console.log(`    ${f}: expected ${JSON.stringify(v.expected)}, got ${JSON.stringify(v.actual)}`);
    }
  }
  console.log("─".repeat(60));
  for (const [f, v] of Object.entries(perField)) {
    console.log(`${f.padEnd(24)} ${((100 * v.ok) / v.total).toFixed(1).padStart(5)}%  (${v.ok}/${v.total})`);
  }
  console.log(`${"ALL FIELDS CORRECT".padEnd(24)} ${((100 * passed) / results.length).toFixed(1).padStart(5)}%  (${passed}/${results.length})`);
  if (!useMock) {
    console.log(`tokens: ${inTok} in / ${outTok} out → ≈ $${cost.toFixed(4)} total, ≈ $${(cost / results.length).toFixed(5)} per call`);
  }

  const outDir = path.join(__dirname, "results");
  fs.mkdirSync(outDir, { recursive: true });
  const file = path.join(outDir, `${new Date().toISOString().replace(/[:.]/g, "-")}${useMock ? "-mock" : ""}.json`);
  fs.writeFileSync(file, JSON.stringify({ model: useMock ? "mock" : MODEL, perField, passed, total: results.length, inTok, outTok, results }, null, 2));
  console.log(`report: ${path.relative(process.cwd(), file)}`);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
