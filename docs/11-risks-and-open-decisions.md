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
| R7 | **Anonymous user loses data** (uninstall before upgrading the account) | Medium | Medium | A Settings warning and a gentle "secure your data" prompt after 10 records | Dev A |
| R8 | **First launch offline** means no UID yet, so nothing can be written | Low | Medium | Retry sign-in; manual-entry screens queue items in the Inbox until signed in | Dev A |
| R9 | **Shader/3D performance** on low-end GPUs | Medium | Low | Lightweight shader, adaptive quality, reduce-motion fallback, test on a cheap phone | Designer + Dev A |
| R10 | Provider **API changes or price changes** | Medium | Medium | Single `callModel()` boundary, eval set, pinned SDK versions | Dev B |
| R11 | **Privacy expectations** (text sent to an AI provider) | Medium | High | Clear onboarding disclosure, no transcript storage by default, documented provider terms | All |
| R12 | Team **inexperience** leads to fragile code | High | Medium | Small PRs, tests on logic, CI, this architecture, asking Claude to explain | All |
| R14 | **Flutter 3.48+ moves Material widgets to a separate `material_ui` package** (`package:flutter/material.dart` is deprecated there) | Certain | Low | CI pinned to 3.47.7. Plan a deliberate upgrade: add `material_ui`, update imports, re-run tests | Dev A |
| R15 | **Bangla TTS voice missing** on some phones | Medium | Low | Detect availability; stay silent instead of mispronouncing; Settings explains how to install the voice | Dev A |
| R16 | **Receipt OCR can't read Bangla script** (ML Kit on-device supports Latin) | High | Low | Latin-digit totals still work; the card always asks to check; vision-AI option later with consent | Dev B |
| R17 | Pressure to add **broad device permissions** (SMS, "all access") | Medium | High | Policy table in docs/03; each new permission needs a product purpose and a Play policy check | Lead |
| R13 | **Losing the Play signing key** | Low | **Critical** | Play App Signing, two offline backups of the upload key | Lead |

## 11.2 Decisions taken in this session

| Decision | Choice | Decided by |
|---|---|---|
| AI provider | Claude API, `claude-haiku-5-5`, server-side only | Team (answered) |
| Firebase plan | Blaze, to be enabled by the team (card entered by the team) | Team (answered) |
| Face & device powers (2026-11-19) | Friendly expressive face; voice replies, contacts picker, calendar intent, on-device receipt scan. All without new permissions | Team (answered) |
| "3D & advanced" scope | GPU shader 3D voice orb + depth/parallax UI, with a reduce-motion fallback | Team (answered) |
| Repo | Public GitHub repo `Ashfaq1306/bolo` | Team (answered) |
| Firebase project | Existing `bolo-bd` (Firestore in `asia-south1`, Android app `bd.bolo.bolo_app`) | Architect (existing setup) |
| Local DB | Firestore offline persistence (ADR-5) | Architect, reversible |
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
