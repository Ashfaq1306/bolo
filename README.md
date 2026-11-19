# বলো Bolo

**A Bangla-first voice-to-action personal assistant for Bangladesh.**
Speak naturally in Bangla, English, or a mix. Bolo turns the sentence into a reminder, task, expense, or money-owed record, checks it with you, and keeps working offline.

> *"kal sokal 10 tay rent dite hobe mone koriye dio"* → ⏰ Reminder · Friday 21 Nov, 10:00 AM → **Save**
> *"aaj lunch e 350 taka khoroch holo"* → 🍽️ Expense · ৳৩৫০ · Food → **Confirm**

| Status | |
|---|---|
| Stage | MVP scaffold (milestones M0–M4 first version, see [docs/10](docs/10-milestones.md)) |
| Platforms | Android (Flutter) |
| Backend | Firebase (`bolo-bd`, region `asia-south1`): Auth, Firestore, Cloud Functions |
| AI | Claude Haiku 5.5 via Cloud Functions (the key is never in the app) |

## Features

- 🎙️ **Voice or typed input**, with a live transcript and a GPU-shader **3D orb** that reacts to your voice
- 🧠 **Intent and field extraction** for reminders, tasks/deadlines, expenses, receivables/payables, settling, and summaries
- ✅ **Confirmation card**: everything is editable, and **money is never saved without an explicit Confirm**
- 🕐 **Asia/Dhaka time** everywhere, with ambiguity handling for "৫টায়" (5 o'clock, but AM or PM?) and "kal" (yesterday or tomorrow?)
- 📴 **Offline**: records are cached on the device, reminders fire without internet, and offline captures wait in an Inbox
- 📊 **Daily summary** computed on the phone (no AI cost)
- 🔒 **Per-user isolation** enforced by tested Firestore rules, a server-side AI quota, and no audio storage
- ♿ Bangla-first UI with Bangla digits, the bundled Hind Siliguri font, screen-reader labels, and a reduce-motion fallback

## Documentation

| # | Document |
|---|---|
| 1 | [Product requirements](docs/01-product-requirements.md) |
| 2 | [User journeys](docs/02-user-journeys.md) |
| 3 | [Feature specifications](docs/03-feature-specifications.md) |
| 4 | [System architecture](docs/04-system-architecture.md) |
| 5 | [Database schema](docs/05-database-schema.md) |
| 6 | [Security architecture](docs/06-security-architecture.md) |
| 7 | [Flutter project structure](docs/07-flutter-project-structure.md) |
| 8 | [Speech-to-text evaluation plan](docs/08-stt-evaluation-plan.md) |
| 9 | [API cost control](docs/09-cost-control.md) |
| 10 | [Milestones](docs/10-milestones.md) |
| 11 | [Risks & open decisions](docs/11-risks-and-open-decisions.md) |
| 12 | [AI accuracy & evaluation](docs/12-ai-accuracy.md) |

## Getting started (developers)

**Prerequisites:** Flutter 3.47+, Node.js 22, Firebase CLI, Java 21 (for the emulators; Android Studio's bundled JBR works), and an Android emulator or phone.

```bash
# 1. Backend: install, build, run the Firebase emulators (free, local, mock AI)
cd functions
npm install
npm run build
cd ..
firebase emulators:start --only auth,firestore,functions --project bolo-bd

# 2. App: run against the emulators (in another terminal)
cd app
flutter pub get
flutter run --dart-define=USE_EMULATORS=true
```

In emulator mode the function uses a **free rule-based mock** (`functions/.env.local` → `MOCK_AI=true`) instead of Claude, so you can test the whole flow without an API key.

### Tests

```bash
cd app && flutter analyze && flutter test                                   # app
cd functions && npm test                                                     # function unit tests
firebase emulators:exec --only firestore --project demo-bolo "npm --prefix functions run test:rules"   # security rules
cd functions && npm run eval                                                 # AI accuracy (real API, ~$0.01)
```

### Deploying to production (one-time setup, done by the team)

1. Firebase console → **bolo-bd** → upgrade to the **Blaze** plan, and add a **budget alert** in Google Cloud Billing.
2. Firebase console → Authentication → enable the **Anonymous** and **Email/Password** providers.
3. Create an Anthropic API key, set a monthly spend limit, then run:
   ```bash
   firebase functions:secrets:set ANTHROPIC_API_KEY
   ```
4. Deploy:
   ```bash
   firebase deploy --only firestore:rules,firestore:indexes,functions
   ```
5. Build the app for production (no `USE_EMULATORS`): `flutter build apk --release` (set up release signing first, see docs/06).

## Security notes

- Secrets live only in Google Secret Manager. Never commit `.env`, keystores, or service-account files (see `.gitignore`).
- `app/lib/firebase_options.dart` and `google-services.json` contain Firebase *identifiers*, not secrets. Protection comes from the security rules and App Check. Restrict the API key to the Android app in Google Cloud Console.
- Report security issues privately to the maintainers instead of opening a public issue.

## License

Not yet chosen. All rights reserved by the Bolo team until a license is added.
Font: Hind Siliguri, © Indian Type Foundry, [SIL Open Font License](app/assets/fonts/OFL.txt).
