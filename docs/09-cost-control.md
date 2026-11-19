# 9. API cost-control strategy

> Prices below come from Anthropic's published API pricing as of November 2026. Firebase free-tier figures are the long-standing published quotas. **Re-check both pricing pages before launch**: prices change.

## 9.1 Where money is spent

| Cost source | Pricing basis | Bolo's exposure |
|---|---|---|
| **Claude API** (`claude-haiku-5-5`) | $0.10 per 1M input tokens, $0.50 per 1M output tokens (prompts ≤ 100K tokens) | Every `parseCommand` call |
| Cloud Functions | Invocations + CPU/memory time; Blaze includes a monthly free tier | Same calls, tiny |
| Firestore | Reads / writes / deletes / storage, with a daily free quota (published as 50K reads, 20K writes, 20K deletes, 1 GiB storage) | Listening screens, writes |
| Speech-to-text | **$0** with the platform recognizer (MVP) | Becomes per-minute if cloud STT is added |
| Notifications | $0 (local) | none |

## 9.2 Estimating cost per user

One `parseCommand` call ≈ **1,600 input tokens** (fixed system prompt about 1,100, the 14-day calendar about 250, the utterance about 50 to 150) plus **≈ 300 output tokens**. The output figure includes the model's internal reasoning, which is billed as output; effort is set to `low` to keep it short.

```
input : 1,600 × $0.10 / 1,000,000 = $0.00016
output:   300 × $0.50 / 1,000,000 = $0.00015
                                     ─────────
per call                             ≈ $0.0003
```

| Usage | Calls / month | AI cost / user / month |
|---|---|---|
| Light (1/day) | 30 | ≈ $0.009 |
| Typical (3/day) | 90 | ≈ $0.03 |
| Heavy (quota cap 40/day, 600/month) | 600 | ≈ $0.19 (worst case) |

**1,000 typical users ≈ $30/month** in AI cost. These are *estimates*. Milestone 3 logs real `usage.input_tokens` / `usage.output_tokens` per call, and you re-calculate from those.

## 9.3 Controls (in order of impact)

1. **Don't call the AI when you don't need to.**
   - The daily summary, lists, and totals are computed on-device, at zero cost.
   - Manual entry forms never call the AI.
   - **Exact-repeat cache:** the same normalised text on the same Dhaka day returns the cached result (stored in memory on the phone), so a double tap does not cost twice.
   - (Later) a **local fast-path parser** for very simple patterns such as "৫০০ টাকা রিকশা" ("৳500 rickshaw").
2. **Keep each call small.**
   - Input is capped at 500 characters.
   - `max_tokens: 1024`, and `effort: "low"`, which suits short extraction tasks.
   - No conversation history is sent: each call is a single turn.
   - The system prompt is kept tight, and few-shot examples are trimmed to the ones that measurably help.
   - **Prompt caching:** the fixed system prompt is placed first and the variable parts last. Caching only works above a model-specific minimum prefix length, so check `usage.cache_read_input_tokens` in the logs. If it stays 0, the prompt is below the minimum and caching gives nothing; that is fine at this size.
3. **Hard limits that can't be bypassed from the app.**
   - The per-user quota (40/day, 600/month) lives in `usage/{uid}`, which only the server can write.
   - Function `maxInstances: 10`, `timeoutSeconds: 20`.
   - App Check before launch.
4. **Budgets and alerts.**
   - Google Cloud Billing → Budgets: set a budget (e.g. $10/month) with email alerts at 50%, 90%, and 100%.
     Note: a budget **alerts**; it does not automatically stop spending.
   - Anthropic Console: set a monthly **spend limit** on the API key's workspace, so a bug cannot run up a large bill.
5. **Observe.** Each call logs `{uidHash, intent, inputTokens, outputTokens, latencyMs}` to Cloud Logging (never the text). Review it weekly during beta.
6. **Firestore read hygiene.** Screens listen only to bounded queries (e.g. this month's expenses, open ledger entries) and never to whole collections. The offline cache also serves repeated reads.

## 9.4 Model choice and switching

- `claude-haiku-5-5` is the cheapest current Claude model. It is used because it fits a short, schema-constrained extraction task.
- Every call goes through one function (`callModel()` in `functions/src/parse/ai.ts`), so a model can be compared on the eval set and switched by changing one constant.
- Quality gate: a change of model or prompt ships only if it scores at least as well on the Bolo eval set ([08 § 8.3](08-stt-evaluation-plan.md#83-test-set-bolo-speech-100)).

## 9.5 What the team must do manually

- [ ] Enable **Blaze** on `bolo-bd` (Firebase console → Usage and billing).
- [ ] Create a **budget alert** in Google Cloud Billing.
- [ ] Create an Anthropic API key, set a **spend limit**, and run `firebase functions:secrets:set ANTHROPIC_API_KEY`.
