# 6. Security & privacy architecture

## 6.1 What we are protecting

| Asset | Sensitivity | Main threat |
|---|---|---|
| Users' financial records (expenses, who owes whom) | **High** | Another user reading or changing them; leaks |
| Reminders/tasks (can reveal health, location, habits) | Medium-high | Same as above |
| Anthropic API key | **High** (costs money) | Extraction from the app, then abuse |
| Firebase project budget | High | Bots calling `parseCommand` in a loop |
| Voice audio | High | Recording or storage |

## 6.2 Trust boundaries

```
[ Phone (untrusted: user controls it, APK can be modified) ]
        │  Firebase ID token (+ App Check token)
        ▼
[ Firebase: Security Rules + Cloud Functions (trusted) ] ── secret ──▶ [ Claude API ]
```

**Rule of thumb for beginners:** *anything inside the APK is public.* That covers code, strings, keys, and "hidden" endpoints. Security therefore has to come from the server side: Auth, Rules, Functions, and quotas.

## 6.3 Controls

### Authentication
- Every user has a Firebase Auth UID from the first launch (anonymous), so no data is ever written without an owner. **Superseded (2026-11-27) by [ADR-11](adr/0011-guest-data-local-only.md):** guest data is local-only; anonymous users will lose access to personal records once the migration has shipped (docs/13 § 7).
- Email/password linking keeps the same UID.
- The ID tokens the Firebase SDK sends are verified automatically by Firestore and by callable functions.

### Authorization: Firestore Security Rules (`firestore.rules`)
- **Default deny:** anything not matched is rejected.
- `users/{uid}/**` can be read and written **only if `request.auth.uid == uid`**.
- **Field validation on every write:** allowed keys only, correct types, string lengths, `amountPoisha` an `int` within limits, and enum values checked.
  This stops a modified app from writing garbage or giant documents.
- `usage/**` is **denied to all clients**; only the Admin SDK in Functions can write it.
- Rules are **unit-tested** with the Firestore emulator (`functions/test/rules.test.ts`).

### Secrets
- `ANTHROPIC_API_KEY` is stored in **Google Secret Manager** via `firebase functions:secrets:set ANTHROPIC_API_KEY` and bound only to `parseCommand`.
- It is never written to code, `.env` files in git, logs, or the client.
- `.gitignore` blocks `.env*`, `*.keystore`, `key.properties`, and `service-account*.json`.

> **About `google-services.json` / `firebase_options.dart`:** these contain a Firebase *Web API key*. It is **not a secret**: it only identifies the project, and Google's documentation says it is fine to ship in apps and repos. Data protection comes from Rules and App Check. They are committed so CI can build. **However**, in Google Cloud Console → Credentials, restrict this key to the Android app (package `bd.bolo.bolo_app` plus the SHA-1) and to the Firebase APIs it needs (Milestone 6).

### Abuse and cost protection (see also [09](09-cost-control.md))
1. Auth required for `parseCommand`.
2. **App Check** (Play Integrity on Android) with `enforceAppCheck: true` on the function before public launch. It proves that requests come from the genuine app on a real device. Development uses the debug provider.
3. A **per-user daily quota** (default 40/day, 600/month), enforced in a Firestore transaction **before** the AI call.
4. **Input caps:** ≤ 500 characters, and `max_tokens` ≤ 1024 on the AI call.
5. **`maxInstances: 10`** on the function.
6. A **billing budget alert** on the Google Cloud project, and a monthly spend limit on the Anthropic Console.

### AI-specific risks
| Risk | Control |
|---|---|
| **Prompt injection** ("ignore instructions and …") | The model has no tools and no database access; it can only return JSON matching a schema. The worst case is a wrong card that the user rejects. |
| Hallucinated fields | Server-side schema plus range validation, client-side validation again, and user confirmation (mandatory for money). |
| Sensitive text sent to a third party | Users are told in the privacy notice that typed or spoken *text* is sent to an AI provider for understanding. Only the utterance and the date context are sent, never past records or profile data. The function does **not** log the text. |
| Provider data retention | Before launch, read and record Anthropic's current commercial terms on API data retention and training in `PRIVACY.md`. **Don't assume.** |

### Privacy by design
- **No audio storage.** Bolo never records audio files; it only consumes the recognizer's text result. On Android, the system recognizer (usually Google's) may process audio on-device or in the cloud depending on the device and settings. This must be disclosed.
- **Transcripts are off by default** (`storeTranscripts: false`).
- **Data minimisation:** no location, SMS, call-log, file or accessibility access. Contacts (`READ_CONTACTS`) and calling (`CALL_PHONE`) are asked for only the first time the user asks Bolo to call someone. The contact search runs on the phone and **contact data is never sent to the AI or Firebase** (the AI only sees the spoken name). Calendar and camera use system intents (photos are deleted after on-device reading). See the device access policy in [03](03-feature-specifications.md#device-access-policy).
- **Hands-free listener:** off by default. When on, it is an Android foreground service with a permanent notification and a Stop button. Speech is recognised **offline** (Vosk) against a tiny grammar, and audio is never stored or sent.
- **Lock screen:** when woken over the lock screen, Bolo shows only the robot and the transcript (no totals, reminders or tabs). Calls, music and apps require the user to unlock first (`requestDismissKeyguard`).
- **Calls are never placed without confirmation** (a tap, or a spoken হ্যাঁ/yes on the call card).
- **User rights:** delete-all-data (function) and export (JSON) before public launch.
- **Logs:** functions log only the UID hash, intent, latency, and token counts, never the user's text.

### Device and app
- Android `allowBackup="false"`, so the Firestore cache is not copied into cloud/adb backups.
- Release builds use R8 obfuscation (`--obfuscate --split-debug-info`). This is a speed bump, not security.
- Signing keys are kept **outside the repo** and backed up in two places (losing one means you can never update the Play listing).

## 6.4 Security checklist per milestone

- [ ] M1: Rules default-deny plus owner-only, rules tests passing, `.gitignore` for secrets
- [ ] M3: Secret in Secret Manager, function requires auth, quota implemented, no text in logs
- [ ] M5: Financial confirmation covered by tests (no code path saves money records without `confirmed == true`)
- [ ] M6: App Check enforced, API key restricted, budget alerts, privacy policy, delete-my-data, Play data-safety form
