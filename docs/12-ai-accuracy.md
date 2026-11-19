# 12. Making the AI accurate (and keeping it that way)

## The honest picture

- Bolo uses **Claude Haiku 5.5 through the API**. We do not train or fine-tune the model itself.
- Accuracy comes from **(1)** a precise prompt, **(2)** a schema-constrained output, **(3)** deterministic code checks, **(4)** a measured test set, and **(5)** the confirmation card.
- **No system is 100% accurate on real speech.** Speech recognition errors, slang, and genuinely ambiguous sentences ("kal" can mean yesterday *or* tomorrow) will always exist.
- So the goal is: **high measured accuracy, and every mistake is caught by the user before it is saved.**

| Target (on the golden set) | MVP | Public launch |
|---|---|---|
| Intent correct | ≥ 95% | ≥ 97% |
| Amount correct | ≥ 97% | ≥ 99% |
| Date/time correct | ≥ 90% | ≥ 95% |
| All fields correct | ≥ 85% | ≥ 90% |

## The layers that produce accuracy

| Layer | Where | What it does |
|---|---|---|
| Prompt | `functions/src/parse/prompt.ts` | Defines intents and Bangla/Banglish rules (কাল tense, AM/PM words, number words like দেড়/আড়াই/সাড়ে), with worked examples |
| Calendar table | `functions/src/parse/calendar.ts` | The model *picks* dates from a precomputed Dhaka calendar instead of doing date arithmetic, which LLMs often get wrong |
| Structured output | `functions/src/parse/ai.ts` + `schema.ts` | The response must match the JSON schema, so the server never has to parse free text |
| Server validation | `functions/src/parse/validate.ts` | Drops impossible dates and absurd amounts, and runs an **amount cross-check**: if the amount isn't one of the numbers the user actually said, confidence drops to 0.5 and the card asks the user to check |
| App validation | `app/lib/features/command/parsed_command.dart` | Validates everything again in Dart |
| Human confirmation | Confirmation card | Every field is editable. Money **always** requires Confirm |

## The improvement loop

1. **Measure.** `cd functions && npm run eval` runs all cases in `eval/golden.json` against the real model and prints per-field accuracy, every failure, and the cost (~US$0.0003 per case, so ~$0.01 for the current 40 cases).
2. **Collect failures.** During beta, whenever a user corrects a field on the card, that is a failure case. Add the sentence (with names and amounts changed, and no personal data) to `golden.json` with the correct expected output.
3. **Fix the cheapest layer first.**
   1. Code checks (deterministic, free).
   2. Then prompt rules or examples.
   3. Then, only if needed, a stronger model (`MODEL` in `ai.ts`).
4. **Re-run the eval.** Keep a change **only if the overall score goes up and nothing that passed before now fails.**
5. **Grow the set.** Aim for 200+ cases before public launch, balanced across the buckets in [08 § 8.3](08-stt-evaluation-plan.md#83-test-set-bolo-speech-100).

`npm run eval:mock` runs the free rule-based mock instead. It only checks that the harness works; the mock is deliberately weak (about 22% all-fields-correct), which shows why the real model is used.

## Running the real eval

```bash
# PowerShell
$env:ANTHROPIC_API_KEY = "sk-ant-..."   # your key; never commit it
cd functions
npm run eval
```
