# 1. Product Requirements Document (PRD): Bolo (বলো)

| | |
|---|---|
| Status | Draft v1 (MVP) |
| Owners | Bolo team (2 developers, 1 UI/UX designer) |
| Last updated | 2026-11-19 |

## 1.1 Problem

Many people in Bangladesh manage their day through memory, scraps of paper, and chat messages to themselves:
"pay Rahim 500 taka on Friday", "the electricity bill is due on the 10th", "Karim still owes me 2,000".
Most productivity apps are English-first, form-heavy, and assume the user wants to type.
People speak naturally in Bangla, English, or a mix (*"kal sokal 9 tay meeting ache, remind koro"*). No mainstream assistant turns that kind of speech into reliable structured records.

## 1.2 Product vision

> Speak one sentence. Bolo understands it, checks it with you, and remembers it.

Bolo is a **voice-to-action personal assistant**. It is not a chatbot.
Every conversation should end in a concrete, reviewable record: a reminder, a task, an expense, or a money-owed entry.
It should also keep working when the internet doesn't.

## 1.3 Target users (MVP)

| Persona | Description | Key need |
|---|---|---|
| **Nusrat, university student** (primary) | 20, mixes Bangla and English, budget-conscious, Android mid-range phone | Assignment deadlines, small expenses, money lent to friends |
| **Rafiq bhai, small shop owner** | 38, prefers Bangla, types slowly, patchy mobile data | Who owes him money (*baki*), supplier payments, reminders |
| **Shirin, office worker** | 29, English at work and Bangla at home | Meetings, bill due dates, monthly spending view |

Constraints that hold for all three: **Android first** (most users in Bangladesh are on Android), low-to-mid-range devices, intermittent connectivity, data costs matter, and sensitive financial information.

## 1.4 Goals and non-goals

**Goals (MVP)**
1. Capture a reminder, task, expense, or receivable/payable entry from a single spoken sentence in Bangla, English, or a mix.
2. Never save a financial record without the user explicitly confirming it.
3. Resolve dates and times correctly in **Asia/Dhaka**, and *ask* instead of guessing when a date or time is ambiguous.
4. Keep existing records and scheduled reminders usable with no internet.
5. Keep AI cost per active user under about **US$0.05/month** (see [09-cost-control](09-cost-control.md)).
6. Keep each user's data private and isolated.

**Non-goals (MVP)**: chatbot small talk, sending money or making payments (bKash, Nagad, banks), reading SMS, calendar sync, shared or family accounts, iOS release, wake-word ("Hey Bolo"), and voice replies (TTS). Each of these can be reconsidered after the MVP.

## 1.5 MVP scope

| # | Capability | Priority |
|---|---|---|
| F1 | Voice input (tap to talk) with live transcript; typed input as an equal fallback | Must |
| F2 | Speech-to-text for `bn-BD` and `en-US`, with code-mixed speech handled as well as the provider allows | Must |
| F3 | Intent recognition and field extraction (server-side AI) | Must |
| F4 | Confirmation card: review and edit before saving; mandatory for money | Must |
| F5 | Reminders with local notifications (work offline) | Must |
| F6 | Tasks and deadlines (due date, optional reminder, done/undone) | Must |
| F7 | Expense records (amount, category, note, date) | Must |
| F8 | Money receivable/payable ledger (person, amount, due date, settle) | Must |
| F9 | Daily summary (on-device, no AI cost) and an optional evening notification | Should |
| F10 | Authentication: start instantly (anonymous), upgrade to email later | Must |
| F11 | Sync across devices for signed-in users; offline cache | Must |
| F12 | Bangla-first UI, English toggle, Bangla digits, accessibility | Must |
| F13 | Delete my data / export my data | Should (required before public launch) |

Full details are in [03-feature-specifications](03-feature-specifications.md).

## 1.6 Functional requirements (summary)

- **FR-1** The user can start voice capture from the home screen in one tap. Listening stops on a second tap or after silence.
- **FR-2** The transcript is shown live and can be edited before it is sent for understanding.
- **FR-3** The system classifies the utterance into one of these intents: `create_reminder`, `create_task`, `add_expense`, `add_receivable`, `add_payable`, `settle_ledger`, `query_summary`, `unknown`.
- **FR-4** The system extracts the fields for that intent and marks each uncertain field (for example an ambiguous time).
- **FR-5** Before saving, the system shows a confirmation card in Bangla (or English) with every extracted field editable.
- **FR-6** Financial intents (`add_expense`, `add_receivable`, `add_payable`, `settle_ledger`) are saved **only** after an explicit tap on "Confirm". There is no auto-save and no voice-only confirmation in the MVP.
- **FR-7** When a date or time is ambiguous, the card shows the interpretation Bolo chose *and* asks the user to choose or confirm it.
- **FR-8** Reminders fire as local notifications at the right Dhaka time, even when the device is offline.
- **FR-9** All records can be listed, edited, completed or settled, and deleted manually, without voice.
- **FR-10** A daily summary shows today's reminders, open tasks and deadlines, today's spending, and money owed in both directions.

## 1.7 Non-functional requirements

| Area | Requirement |
|---|---|
| Privacy | Audio never leaves the device through Bolo's own code (the STT provider's behaviour is documented separately). Transcripts are not stored by default. Only the user can read their records. |
| Security | All API secrets live server-side (Cloud Functions Secret Manager). Firestore rules enforce per-user isolation and field validation. See [06-security](06-security-architecture.md). |
| Performance | Voice to confirmation card in < 3 s on 4G (p50). App cold start < 2.5 s on a mid-range device. The 3D orb holds 60 fps on mid-range devices and degrades gracefully below that. |
| Offline | Existing records readable and editable offline. Reminders fire offline. AI parsing requires connectivity, and offline speech goes to a queued "inbox" that the user can retry. |
| Time | All times are interpreted and displayed in Asia/Dhaka (UTC+06:00) and stored as UTC timestamps. |
| Accessibility | Screen-reader labels on every control, text scaling up to 200%, contrast ≥ 4.5:1, touch targets ≥ 48 dp, "reduce motion" disables the 3D animation, and every voice action also has a non-voice path. |
| Cost | Monthly AI cost under the budget in [09](09-cost-control.md). Hard per-user daily quota. Firebase budget alert configured. |
| Maintainability | Feature-first folders, a repository pattern, tests for parsing, money and dates, CI on every push. |

## 1.8 Success metrics (first 8 weeks after beta)

- **Capture success rate:** at least 80% of voice captures reach a saved record without the user retyping the whole thing.
- **Parse accuracy (offline eval set):** intent at least 95% and key fields at least 90% on the team's Bangla/mixed test set (see [08](08-stt-evaluation-plan.md)).
- **Financial safety:** 0 financial records saved without confirmation (enforced in code and covered by tests).
- **Retention:** at least 30% of beta users active in week 4.
- **Cost:** AI cost under US$0.05 per monthly active user.

## 1.9 Assumptions and dependencies

- Android's on-device or Google speech recognizer is available on the target phones. **This must be verified per device**; see the evaluation plan in [08](08-stt-evaluation-plan.md).
- The Claude API (`claude-haiku-5-5`) is used for intent and field extraction, called only from Cloud Functions.
- The Firebase project `bolo-bd` is on the **Blaze** plan, because Cloud Functions require it.
- The team will create an Anthropic API key and store it with `firebase functions:secrets:set`.

## 1.10 Release criteria for public launch (beyond MVP)

Privacy policy published, data deletion working, App Check enforced, Play Store data-safety form completed, the evaluation set passing its targets, and a crash-free rate of at least 99% in closed beta.
