# 8. Speech-to-text evaluation plan (Bangla and code-mixed speech)

> **Honesty rule for this document:** a capability is marked as "documented" only when the provider's own documentation states it. Everything else is a **hypothesis to test**. Provider features, prices, and language lists change, so re-check every provider's docs and pricing page on the day you run this evaluation, and record the date.

## 8.1 Why evaluate at all?

STT errors are the biggest quality risk in Bolo. If "৫০০" is heard as "৫০", the most careful AI parsing cannot fix it. Bangladeshi speech brings specific challenges:
- **Code-mixing** inside a sentence (*"kal meeting ta reschedule koro"*, "reschedule tomorrow's meeting").
- **Numbers and money** in several forms: "পাঁচশো", "five hundred", "500", "৫০০".
- **Regional accents** (Chittagonian, Sylheti, and others), **noisy environments** (rickshaw, bazaar, bus), and low-end microphones.
- **Names** of people and places.

## 8.2 Candidates

| Candidate | How Bolo would use it | What to verify (do not assume) |
|---|---|---|
| **A. Android platform recognizer** via `speech_to_text` (MVP default) | On-device API; usually backed by Google's recognizer | Whether `bn-BD`/`bn-IN` are listed by `locales()` on each test phone; whether offline recognition works after downloading the Bangla pack; whether English words inside Bangla speech come back in Latin or Bangla script; session length limits |
| **B. Google Cloud Speech-to-Text** | Upload audio from the app → Cloud Function → API | Current Bangla model/locale support and its language-code list; pricing per minute; whether alternative-language hints help with code-mixing |
| **C. Open-weight multilingual models** (e.g. Whisper-family checkpoints, or community Bangla fine-tunes) | Self-hosted server, or on-device if small enough | Bangla word-error rate on *our* set; latency on a CPU or cheap GPU; model licence; on-device feasibility (size/RAM) |
| **D. Other commercial APIs** that state Bangla support in their docs | Through a server function | Bangla support stated in official docs; price; data-retention terms |

You can run candidate C on your RTX 4060 for the evaluation itself. A production server GPU is a separate cost decision.

## 8.3 Test set ("Bolo-Speech-100")

Record **100 utterances** (WAV, 16 kHz mono) with at least **6 speakers**: men and women, at least two regional accents, and including your own team and friends.

| Bucket | Count | Example |
|---|---|---|
| Pure Bangla reminders/tasks | 20 | "আগামীকাল সকাল আটটায় ওষুধ খাওয়ার কথা মনে করিয়ে দিও" ("remind me to take my medicine tomorrow at 8 am") |
| Pure Bangla money | 20 | "রহিমকে পাঁচশো টাকা দিতে হবে শুক্রবার" ("I have to give Rahim 500 taka on Friday") |
| Code-mixed | 30 | "aaj lunch e 350 taka spend korlam", "CSE215 assignment er deadline 25 tarikh" |
| English (BD accent) | 10 | "Remind me to call the bank at 3 pm" |
| Noisy (street/fan/TV) | 10 | Any of the above, recorded outdoors |
| Names and numbers stress | 10 | "তিন হাজার সাতশো পঞ্চাশ" ("three thousand seven hundred fifty"), "Shahriar", "Mirpur 10" |

For each utterance, write the **reference transcript** and the **expected structured result** (intent, amount, date, person). The same file becomes the AI parsing evaluation set ([09](09-cost-control.md) uses it too).

Consent: get written consent from each speaker. Store the recordings **outside the public repo** (a private Drive folder), and commit only the text references.

## 8.4 Metrics

| Metric | Why | Target for MVP choice |
|---|---|---|
| **WER / CER** (word/character error rate) on Bangla | General accuracy (CER suits Bangla better because word segmentation varies) | CER ≤ 15% |
| **Entity accuracy**: amount, date/time words, person name | What actually matters to Bolo | Amount ≥ 97%, date/time ≥ 92%, name ≥ 85% |
| **End-to-end task success** (STT → AI → correct card) | The real user outcome | ≥ 85% |
| Latency (end of speech → text) | UX | p50 ≤ 1.0 s |
| Offline availability | Requirement | Record yes/no per device |
| Cost per minute | Budget | Must fit [09](09-cost-control.md) |
| Privacy (where audio is processed, retention) | Trust | Must be documentable |

## 8.5 Procedure

1. **Phones:** at least 3 real Android devices (one low-end around ৳12k, one mid-range, one recent). Record each device's model, Android version, and Google app version.
2. **Platform STT (A):** use the in-app **STT test screen** (debug build, Milestone 2). It plays nothing; you speak live and it logs the transcript and timing. To make the run repeatable, play the recorded WAV through a speaker at a fixed distance and volume.
3. **Cloud/open models (B, C, D):** a small Python script (`tools/stt_eval/`, Milestone 2) feeds the WAV files and writes a CSV of hypotheses.
4. **Scoring:** a script computes CER/WER, after normalising Bangla digits and punctuation, and the entity accuracies.
5. **End-to-end:** pass each hypothesis through `parseCommand` (emulator, real AI) and compare against the expected structured result.
6. **Decide** using the weighted score: entity accuracy 40%, end-to-end 30%, cost 15%, latency 10%, privacy 5%.

## 8.6 Expected outcome and fallback plan

- **Hypothesis:** the platform recognizer is good enough for clear speech, with mixed results on code-mixing. It is free, so it remains the MVP default if it meets the targets on mid-range phones.
- **If it fails** on code-mixing or on low-end devices, add a "high accuracy mode" (record a short clip and send it to the winner of B, C, or D through a function) with its own quota, because that has a per-minute cost.
- **Always:** the editable transcript and the confirmation card limit the damage of STT errors, especially for money.

## 8.7 Decision record

| Date | Devices | Candidate | CER | Amount acc. | E2E | Decision |
|---|---|---|---|---|---|---|
| _(fill in)_ | | | | | | |
