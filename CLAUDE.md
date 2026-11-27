# Bolo: notes for Claude and contributors

Bangla-first voice/chat personal assistant. Flutter app in `app/`, Firebase backend in `functions/`, docs in `docs/`.

## Read first
- Architecture: `docs/04-system-architecture.md`, then the newer decisions in `docs/adr/` (ADR-10..12 supersede parts of docs/04).
- Current state and migration plan: `docs/13-phase0-guest-data-audit.md`.
- Roadmap and phases: `docs/10-milestones.md`. Open decisions: `docs/11` § 11.3–11.4.

## Toolchain
- Flutter **3.47.7** (pinned in `.github/workflows/ci.yml`), Java 21, Node 22.
- Don't commit `pubspec.lock` changes caused by a different local Flutter version. If your default `flutter` is newer, install 3.47.7 next to it (`git clone -b 3.47.7 --depth 1 https://github.com/flutter/flutter.git ~/flutter-3.47.7`) and use that.
- Drift code generation (only `lib/data/`): `dart run build_runner build`. Commit the generated `*.g.dart`; CI doesn't run the generator.
- Checks: `flutter analyze`, `flutter test` (in `app/`); `npm test`, `npm run test:rules` (in `functions/`).

## Rules that must not be broken
- **AI only proposes.** Records are written only by app code after validation and an explicit user tap (`CommandSaver(userConfirmed: true)`). Money always needs Confirm.
- **Guest data is local-only** (ADR-11; Phase 1 implements it: `DriftRecordsRepository`, `app/lib/data/`). Don't add features that make guests depend on Firestore, and don't add "sign in to an existing account" or tighten Firestore rules before the guest migration (docs/13 § 11) has shipped.
- Money is integer poisha (minor units). Time logic goes through `DhakaTime`.
- Riverpod without code generation; feature-first folders under `app/lib/features/`.
- Never log user text, transcripts, audio or secrets. The Anthropic key lives only in Secret Manager.
- `bolo-bd` is the **development** project (ADR-12). No deploys (rules, functions, config), no billing/Blaze changes, no Firebase project creation, no anonymous-account cleanup without explicit approval.
- Don't delete or modify existing Firestore user data without an approved migration plan.
