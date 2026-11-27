# 10. Milestone-by-milestone development plan

These estimates assume two part-time student developers (about 10–15 h/week each) and one designer. Each milestone ends with a **demo** and a **definition of done (DoD)**. Do not start the next milestone until the DoD is met, because unfinished foundations get more expensive to fix later.

| # | Milestone | Duration | Status |
|---|---|---|---|
| M0 | Setup & foundations | 1 week | ✅ scaffolded in this repo |
| M1 | Data layer: records CRUD (manual entry), rules | 2 weeks | ✅ first version scaffolded |
| M2 | Voice capture + 3D orb + STT test screen | 1–2 weeks | ✅ first version scaffolded |
| M3 | AI parsing function + confirmation card | 2 weeks | ✅ first version scaffolded (needs the API key and Blaze) |
| M4 | Reminders & notifications, daily summary | 1–2 weeks | ✅ first version scaffolded |
| M5 | Polish: Bangla UX, accessibility, ambiguity flows, inbox | 2 weeks | partly |
| M6 | Hardening: App Check, delete data, privacy, beta release | 2 weeks | ⏳ |
| M7 | Closed beta (20–50 users) and STT/AI evaluation run | 3–4 weeks | ⏳ |

> **Added 2026-11-27.** Shipped outside this plan in v1.1: robot face, voice replies, hands-free wake word (Vosk), calls / music / open apps, receipt scan, calendar intent, Remote Config update prompt, signed APK releases, Voice check diagnostics. The Phase 0 audit ([docs/13](13-phase0-guest-data-audit.md)) adds Phases 1–4 below, which come **before** M6. M2's "STT test screen" is partly covered by Settings → Voice check.

---

### M0: Setup and foundations
- Repo, CI (analyze + test), Firebase project `bolo-bd` linked (`flutterfire configure`), emulators running.
- Theme, fonts, localisation skeleton, Riverpod set up, anonymous sign-in.
- **DoD:** `flutter test` and the functions tests pass in CI, and the app launches on the emulator signed in anonymously.
- **Learning focus:** Git branching and pull requests, what Riverpod providers are, and how Firebase emulators work.

### M1: Data layer
- Models plus repositories for reminders, tasks, expenses, and ledger, each with a manual add/edit/delete screen.
- `firestore.rules` with validation, plus rules unit tests.
- Money (poisha) and Dhaka-time utilities, with unit tests.
- **DoD:** every record type can be created and listed manually, works offline (airplane-mode test), and the rules tests pass.

### M2: Voice and the 3D orb
- `SpeechService` (`speech_to_text`), locale chip, live transcript, and sound-level-driven orb shader with a reduce-motion fallback.
- A debug STT test screen for the evaluation in [08](08-stt-evaluation-plan.md).
- **DoD:** Bangla speech is transcribed on at least 2 real phones, the orb runs at 60 fps on a mid-range phone, and TalkBack can operate the capture flow.

### M3: AI parsing
- `parseCommand` function (auth, quota, Claude structured output, validation), the Dart `CommandService`, and the confirmation card for all intents.
- 30 golden test cases (text → expected JSON) run against the emulator.
- **DoD:** at least 90% of the golden cases parse correctly, financial intents can't be saved without Confirm (tested), and logs contain no user text.

### M4: Reminders and summary
- Scheduling, re-scheduling on start, exact/inexact fallback, notification permission UX, the Today screen, and the daily summary notification.
- **DoD:** a reminder set for +2 min fires with the phone in airplane mode, and also after a reboot.

### M5: Polish
- Ambiguity chips (AM/PM, relative day, "next Friday"), Inbox for offline captures, email account linking, empty states, designer review, Bangla copywriting review, and accessibility audit (TalkBack, 200% text).
- **DoD:** the designer signs off, and the accessibility checklist passes.

### M6: Hardening and release prep
- App Check (Play Integrity) enforced, API key restrictions, `deleteMyData`, a privacy policy page, the Play Console data-safety form, release signing, R8, crash reporting (Firebase Crashlytics), and budget alerts.
- **DoD:** a signed release AAB passes the internal testing track, and the security checklist in [06](06-security-architecture.md) is complete.

### M7: Closed beta and evaluation
- Run the evaluation in [08](08-stt-evaluation-plan.md), recruit 20–50 testers, collect feedback weekly, and track the metrics in [01 § 1.8](01-product-requirements.md#18-success-metrics-first-8-weeks-after-beta).
- **DoD:** the metrics are measured, and a go/no-go decision is made for an open beta.

---

## Phases after the Phase 0 audit

Proposed by [docs/13](13-phase0-guest-data-audit.md); each phase needs explicit founder approval before it starts. Cloud Functions and Blaze stay in M6.

| Phase | Scope | Exit criteria | Size |
|---|---|---|---|
| 0 | Audit and migration design | ✅ done (docs/13, ADR-10..12); decisions in docs/11 § 11.4 pending | – |
| 1 Data foundation (**in progress**, branch `phase1-data-foundation`) | Drift DB; device identity; offline first launch; `DriftRecordsRepository`; Firestore-free models; inbox into Drift; save `legacy_anon_uid`; journaled migration (scenarios A–C); guests stop writing to Firestore | Airplane-mode first launch works; migration tests pass; all existing tests pass. Code + unit tests done 2026-11-27; device tests (airplane mode, upgrade from 1.1 on both phones) pending | L (≈ 3–4 weeks part-time) |
| 2 Registered sync | Outbox push/pull, tombstones, conflict UI; sign in to an existing account with the keep/import/separate choice; Google sign-in | Two-device tests pass; no duplicates after interrupted retries | L |
| 3 Security & reliability | Rules: anonymous read-only, then none; minimum app version; App Check; delete/export; sync monitoring; toolchain upgrade | Rules tests for every case; staged rollout | M |
| 4 Assistant foundation | Unified voice + chat, tool registry, context, user-controlled memory; AI function deploy (M6, needs Blaze approval) | Separate approval | L |

## How to work as a team (recommended)

- **One feature = one branch = one pull request.** The other developer reviews it, and CI must be green.
- **Weekly 30-minute sync:** demo what changed, update this file's status column, and pick next week's tasks.
- **The designer works one milestone ahead** (designs M2 while developers build M1).
- **Use Claude well:** ask it to explain code it writes, to write tests first, and to review your PRs. Do not merge code you don't understand.
