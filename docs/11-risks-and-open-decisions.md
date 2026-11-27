# 11. Technical risks & open decisions

## 11.1 Risk register

| # | Risk | Likelihood | Impact | Mitigation | Owner |
|---|---|---|---|---|---|
| R1 | **Bangla / code-mixed STT accuracy** is too low on some phones | High | High | Evaluation plan ([08](08-stt-evaluation-plan.md)), editable transcript, confirmation card, typed fallback, provider swappable behind `SpeechService` | Dev A |
| R2 | The Bangla recognizer is **missing or online-only** on some devices | Medium | Medium | Detect with `locales()`, show help to install the language pack, typed fallback | Dev A |
| R3 | **Wrong amount or direction** saved in the ledger | Medium | **High** (trust) | Mandatory Confirm, large amount display, direction icon and colour, > ৳10 lakh double-check, tests | Dev B |
| R4 | **Date misinterpretation** ("kal" = yesterday/tomorrow, AM/PM) | High | Medium | Ambiguity tags, chips, exact date displayed on the card, server and client validation | Dev B |
| R5 | **Android exact alarms** restricted (Android 12+ needs `SCHEDULE_EXACT_ALARM`, which is not granted by default on 14+; OEM battery killers such as Xiaomi and Oppo delay alarms) | High | Medium | Inexact fallback with an honest message, a "disable battery optimisation" help screen, re-schedule on app open | Dev A |
| R6 | **AI cost abuse** via a scripted client | Medium | High | Auth, quota, App Check, `maxInstances`, budgets, Anthropic spend limit | Dev B |
| R7 | **Anonymous user loses data** (uninstall before upgrading the account) | **High** (confirmed, docs/13 L1) | **High** | Settings warning exists; the "after 10 records" prompt is **not implemented**. Real fix: local-only guest data (ADR-11) | Dev A |
| R8 | **First launch offline** means no UID yet, so nothing can be written | Low | **High** (confirmed: the app is unusable) | Current code only offers a retry. Fix: offline first launch with Drift (ADR-10/11) | Dev A |
| R9 | **Shader/3D performance** on low-end GPUs | Medium | Low | Lightweight shader, adaptive quality, reduce-motion fallback, test on a cheap phone | Designer + Dev A |
| R10 | Provider **API changes or price changes** | Medium | Medium | Single `callModel()` boundary, eval set, pinned SDK versions | Dev B |
| R11 | **Privacy expectations** (text sent to an AI provider) | Medium | High | Clear onboarding disclosure, no transcript storage by default, documented provider terms | All |
| R12 | Team **inexperience** leads to fragile code | High | Medium | Small PRs, tests on logic, CI, this architecture, asking Claude to explain | All |
| R14 | **Flutter 3.48+ moves Material widgets to a separate `material_ui` package** (`package:flutter/material.dart` is deprecated there) | Certain | Low | CI pinned to 3.47.7. Plan a deliberate upgrade: add `material_ui`, update imports, re-run tests | Dev A |
| R15 | **Bangla TTS voice missing** on some phones | Medium | Low | Detect availability; stay silent instead of mispronouncing; Settings explains how to install the voice | Dev A |
| R16 | **Receipt OCR can't read Bangla script** (ML Kit on-device supports Latin) | High | Low | Latin-digit totals still work; the card always asks to check; vision-AI option later with consent | Dev B |
| R17 | Pressure to add **broad device permissions** (SMS, "all access") | Medium | High | Policy table in docs/03; each new permission needs a product purpose and a Play policy check | Lead |
| R18 | Wake word **false alarms or misses** with real voices, accents and noise (the PC test used synthetic voices only) | Medium | Medium | Sensitivity setting; grammar with competitor words; test with 10+ real speakers and tune thresholds | Dev B |
| R19 | **Battery drain** from the always-on listener | Medium | Medium | Off by default; small offline model; pauses while Bolo listens/speaks; measure drain on 3 phones before recommending it | Dev B |
| R20 | **Google Play policy** for `CALL_PHONE`, `READ_CONTACTS`, microphone foreground service and full-screen intent (APK sharing is unaffected) | High | High | Tie each permission to a visible feature; prepare the Play declarations; if the full-screen intent is refused, only the heads-up notification appears | Lead |
| R21 | **Guest data migration done in the wrong order** (rules tightened or existing-account sign-in added before guests are migrated) | Medium | **Critical** | Release order in docs/13 § 11; anonymous read-only grace period | Lead |
| R22 | **Silent rollback** of rejected Firestore writes | Low | Medium | Outbox with visible `conflict` state (ADR-10) | Dev B |
| R23 | **Toolchain drift** (local Flutter 3.50 vs CI 3.47.7: needs AGP ≥ 9.1.1, Kotlin plugin ≥ 2.4.10, rewrites `pubspec.lock`) | High | Medium | Use 3.47.7 locally; upgrade in one reviewed change | Dev A |
| R24 | **Quota bypass** by creating new anonymous accounts (App Check off) | Medium | High | App Check, global daily ceiling, limited anonymous AI use before M6 deploy | Dev B |
| R13 | **Losing the Play signing key** | Low | **Critical** | Play App Signing, two offline backups of the upload key | Lead |

## 11.2 Decisions taken in this session

| Decision | Choice | Decided by |
|---|---|---|
| AI provider | Claude API, `claude-haiku-5-5`, server-side only | Team (answered) |
| Firebase plan | ~~Blaze, to be enabled by the team~~ **Superseded:** Blaze and Cloud Functions deferred to M6 with explicit approval ([ADR-12](adr/0012-firebase-environments.md)) | Team (answered) |
| Face & device powers (2026-11-19) | Friendly expressive face; voice replies, contacts picker, calendar intent, on-device receipt scan. All without new permissions | Team (answered) |
| "3D & advanced" scope | GPU shader 3D voice orb + depth/parallax UI, with a reduce-motion fallback | Team (answered) |
| Repo | Public GitHub repo `Ashfaq1306/bolo` | Team (answered) |
| Firebase project | Existing `bolo-bd` (Firestore in `asia-south1`, Android app `bd.bolo.bolo_app`) | Architect (existing setup) |
| Local DB | ~~Firestore offline persistence (ADR-5)~~ **Drift/SQLite + explicit sync ([ADR-10](adr/0010-drift-local-first.md))**; guest data local-only ([ADR-11](adr/0011-guest-data-local-only.md)) | Founders (2026-11-27) |
| Firebase environments | `bolo-bd` = development, `bolo-prod` deferred ([ADR-12](adr/0012-firebase-environments.md)) | Founders (2026-11-27) |
| STT for MVP | Platform recognizer; evaluation pending | Architect, pending evaluation |

## 11.3 Open decisions: please answer

1. **Who is the primary user for the first beta**: students (easiest to recruit at NSU) or small shop owners (stronger need for the ledger)? This changes the onboarding copy and the default categories.
2. **Sign-in methods after anonymous:** is email/password enough for the beta, or do you want **Google Sign-In** (needs the SHA-1 of your signing key) or **phone OTP** (SMS costs money)?
3. **Daily AI quota:** is 40 voice commands/day per user acceptable?
4. **Transcript storage:** keep the default **off**? It is more private, but it makes debugging harder during beta. One option is opt-in for beta testers only.
5. **Brand:** does the designer have a palette and logo? The scaffold uses a deep indigo/teal "night sky" palette that can be replaced.
6. **Monetisation (later):** free, freemium (a higher AI quota for paid users), or B2B for shops? This affects how strictly quotas are designed.
7. **iOS:** needed this year? (It requires a Mac and an Apple developer account at $99/year.)
8. **Language default:** Bangla UI by default for everyone, or follow the phone's language?

## 11.4 Open decisions from the Phase 0 audit

From [docs/13](13-phase0-guest-data-audit.md). Phase 1 can start once 1–4 are answered.

1. **Grace period** for anonymous read-only access, and the minimum app version to enforce.
2. **Orphaned anonymous Firestore data** (identity lost): never delete, or a disclosed retention period? This decides the privacy-policy wording.
3. **Guest backup:** none, manual export, or Android backup (`allowBackup` is currently `false`).
4. **Local database encryption** (SQLCipher: more APK size and complexity).
5. **Financial sync conflicts:** keep both versions and ask (recommended), or last write wins.
6. **Tombstone retention** and what happens to an account's local copy on sign-out.
7. **Anonymous AI use:** allowed at all before sign-up, and how much.
8. **Confirmation** for "play music" / "open app", and a stricter voice "yes" for calls.
9. **Live aggregate count** of guest data in `bolo-bd` with a read-only service-account script (docs/13 § 6).
