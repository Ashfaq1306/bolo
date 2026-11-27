# 3. Feature specifications

These are the concrete behaviours developers implement and test against. "MUST" means the behaviour is required and has a test.

---

## F1: Voice input

| Item | Spec |
|---|---|
| Trigger | Tap the orb (and a "Speak" button with the same action, for screen readers). Tap again to stop. |
| Languages | A language chip on the home screen chooses `bn-BD` (default) or `en-US`. The recognizer gets **one** locale per session. See [08](08-stt-evaluation-plan.md) for how mixed speech behaves. |
| Feedback | The orb animates with the microphone sound level, and the live partial transcript is shown under it. |
| Stop | Manual tap, or the platform's end-of-speech detection. A hard cap of 30 s per utterance controls cost and guards against runaway sessions. |
| Errors | Permission denied → typed mode with a hint. Recognizer unavailable → typed mode plus an "install the Bangla speech pack" help link. No speech → "কিছু শুনতে পাইনি" ("I didn't hear anything"), and Bolo stays idle. |
| Typed input | Always available via the keyboard icon. Typed text goes through the same pipeline from F3 onwards. |

## F2: Speech-to-text

- MVP: the **platform speech recognizer** through the `speech_to_text` Flutter plugin. On Android this is the system `SpeechRecognizer` service (usually Google's).
  - No API key is needed and it costs Bolo nothing.
  - Some devices offer offline recognition if the language pack is downloaded. Bolo requests on-device recognition where the plugin and device support it, but must not assume it.
- Behind an interface (`SpeechService`), so a cloud STT provider can be swapped in after the evaluation in [08](08-stt-evaluation-plan.md).
- Audio is **not recorded or stored by Bolo**.

## F3: Intent recognition and extraction

Pipeline: `text → normalise → (cache/quota check) → Cloud Function parseCommand → validated JSON → app-side validation → card`

**Request** (callable function `parseCommand`, region `asia-south1`):
```json
{ "text": "kal 5 tay Rahim ke 500 taka dite hobe", "locale": "bn", "clientNow": "2026-11-19T20:15:00+06:00" }
```
The server ignores `clientNow` for date maths: it uses **its own clock** converted to Asia/Dhaka, so a phone with a wrong clock cannot corrupt dates. `clientNow` is only used to log the skew.

**Response** (validated by a Zod schema on the server and again in Dart):
```json
{
  "intent": "add_payable",
  "confidence": 0.86,
  "title": "Rahim ke taka deoa",
  "amount": 500,
  "currency": "BDT",
  "person": "Rahim",
  "category": null,
  "date": "2026-11-20",
  "time": "05:00",
  "timeAmbiguity": "am_pm",
  "alternatives": [{ "date": "2026-11-20", "time": "17:00" }],
  "reminderOffsetMinutes": null,
  "clarification": "সকাল ৫টা নাকি বিকাল ৫টা?",
  "language": "mixed"
}
```

Intents and their required fields:

| Intent | Required | Optional |
|---|---|---|
| `create_reminder` | title, date, time | repeat (`none`/`daily`/`weekly`) |
| `create_task` | title | date (deadline), time, reminderOffsetMinutes |
| `add_expense` | amount | category, title (note), date (defaults to today) |
| `add_receivable` | amount, person | date (due), title |
| `add_payable` | amount, person | date (due), title |
| `settle_ledger` | person | amount |
| `query_summary` | none | date |
| `unknown` | none | clarification |

Rules:
- The AI **only proposes**. It never writes to the database. The client writes after the user confirms. (Security boundary: see [06](06-security-architecture.md).)
- Server output that fails schema validation is treated as `unknown`, and the user sees manual entry prefilled with the transcript.
- `confidence < 0.6` or `intent == unknown` → the card opens in "choose type" mode.

## F4: Confirmation card

| Intent class | Behaviour |
|---|---|
| Non-financial (reminder, task) **and** no ambiguity **and** confidence ≥ 0.8 | Card shows **Save** as the primary button. After saving, an *Undo* snackbar is shown for 5 s. |
| Non-financial with any ambiguity | Card must show the ambiguity chips. Save is enabled once a choice is made, and the default choice is preselected and visibly highlighted. |
| **Financial** (expense, receivable, payable, settle) | **MUST** require an explicit tap on **Confirm** (নিশ্চিত করুন). No auto-save, no countdown, no voice "yes" in the MVP. The amount is shown in large Bangla digits, and the direction (পাব/দেব, "I'll receive / I'll pay") is shown with an icon and colour. |
| Amount > ৳1,000,000 | A second confirmation dialog. |

Every field on the card is editable inline: title, amount, person, date, time, category, and direction.

## F5: Reminders

- Fields: `title`, `remindAt` (UTC timestamp, displayed in Dhaka), `repeat` (`none`/`daily`/`weekly`), `status` (`pending`/`done`/`cancelled`), `notificationId` (int).
- Scheduling: `flutter_local_notifications.zonedSchedule` with `Asia/Dhaka` TZ. Bolo uses exact alarms when Android allows them (`SCHEDULE_EXACT_ALARM` granted) and falls back to inexact otherwise, telling the user the reminder "may arrive a few minutes late".
- Re-scheduling: on app start and after sign-in, Bolo re-schedules all pending future reminders from the database. This covers a reinstall, a new device, and lost alarms (alarms survive reboot only through the plugin's boot receiver).
- Actions on the notification: "Done" and "Snooze 10 min". (Post-MVP if time is short.)

## F6: Tasks and deadlines

- Fields: `title`, `dueAt?`, `remindAt?`, `priority` (`normal`/`high`), `status` (`open`/`done`), `completedAt?`.
- A "deadline" is simply a task with `dueAt`. If `reminderOffsetMinutes` is given, `remindAt = dueAt − offset` and a notification is scheduled.
- Lists: Today (due today or overdue), Upcoming, Done (last 30 days).

## F7: Expenses

- Fields: `amountPoisha` (**integer**: ৳350.50 → 35050), `currency` (`BDT`), `category`, `note`, `spentAt`.
- **Why integers?** Floating-point numbers cannot represent most decimals exactly (`0.1 + 0.2 != 0.3`). Storing the smallest unit (poisha) as an integer makes sums exact.
- Categories (MVP, fixed list): `food`, `transport`, `bills`, `shopping`, `health`, `education`, `mobile_recharge`, `family`, `other`.
- Views: today's total, this month's total, and per-category totals for the month.

## F8: Receivable / payable ledger

- Fields: `direction` (`receivable` = they owe me, `payable` = I owe them), `person`, `amountPoisha`, `dueAt?`, `status` (`open`/`settled`), `settledAt?`, `note`.
- Partial settlement: post-MVP. In the MVP, settling closes the whole entry.
- Views: total I'll receive, total I owe, and a list grouped by person.

## F9: Daily summary

- Computed on-device from the data: reminders today, tasks due or overdue, today's spend, open receivable/payable totals.
- An optional daily notification at a user-chosen hour (default 21:00), whose text is computed when the app last ran. **Limitation:** a scheduled notification's text is fixed when it is scheduled. Bolo refreshes it each time the app opens and after each record change.
- Zero AI cost.

## F10: Authentication

- MVP: **Anonymous** sign-in at first launch, then upgrade to **Email/Password** with `linkWithCredential` (same UID, so no data migration).
- Later: Google Sign-In (needs SHA-1/SHA-256 fingerprints registered) and phone OTP (SMS is billed per message on Blaze, so it is deferred for cost).
- The anonymous-account risk (data is lost if the app is uninstalled before the account is upgraded) is shown to the user in Settings.

## F11: Sync and offline

- **Decision (MVP):** Cloud Firestore with its **built-in offline persistence** serves as the local database and sync engine. Reads are served from the on-device cache when offline, and writes are queued and sent when the connection returns.
- The Inbox (unparsed offline captures) is stored locally with `shared_preferences`, because it must not be uploaded until the user chooses to.
- **Update (2026-11-27):** the replacement is now decided, see [ADR-10](adr/0010-drift-local-first.md).
- Everything goes through repository interfaces, so the storage can later be replaced by a dedicated local DB (e.g. Drift/SQLite) with a custom sync engine without touching the UI. See [04 § Why Firestore offline instead of a separate local DB](04-system-architecture.md#why-firestore-offline-instead-of-a-separate-local-db).

## F12: Bangla-first UI and accessibility

- Default locale is `bn`, with an English toggle in Settings. Strings live in ARB files (`lib/l10n/app_bn.arb`, `app_en.arb`).
- Bangla digits (০-৯) are used for numbers and money in `bn` mode (`intl` `NumberFormat` with locale `bn`), and amounts use the South Asian grouping (১,০০,০০০).
- The font **Hind Siliguri** (SIL Open Font License) is bundled, so Bangla renders consistently on every device and no font is downloaded at runtime.
- Accessibility: `Semantics` labels on the orb and all icon buttons, no information conveyed by colour alone (direction has an icon and text too), support for system text scale, and "reduce motion" (`MediaQuery.disableAnimations`) replaces the 3D orb with a static gradient.

## F13: Data export and deletion

- Export: a JSON file of all of the user's records, generated on the device and saved via the share sheet. (Post-MVP.)
- Delete: a callable function `deleteMyData` recursively deletes `users/{uid}` and then deletes the Auth user. (Before public launch.)

## F14: Bolo's face (character)

- An animated face is painted over the GPU orb: glossy eyes with catch-lights, eyebrows, a small nose, a mouth, and cheeks. Code: `features/voice/orb_face.dart`.
- **Expressions:**

  | Expression | Shown when | Look |
  |---|---|---|
  | idle | waiting | gentle smile, eyes wander |
  | listening | microphone is on | wide eyes, raised brows, mouth opens with your voice level |
  | thinking | AI is working / scanning | eyes up and to the side, one brow raised |
  | speaking | Bolo is talking | mouth moves in a talking rhythm |
  | happy | after saving | "^ ^" eyes, big smile, blush (2 s) |
  | confused | not understood / error | tilted brows, frown (2 s) |

- Blinks every 2.5–5.5 s. Eyes follow the user's finger anywhere on the home screen.
- The face shifts slightly toward where it looks, so it seems to turn on the sphere.
- Reduce motion shows a static face with no blinking or tracking.

## F15: Voice replies (Bolo talks back)

- Uses the phone's own text-to-speech (`flutter_tts`). No permission is needed, and no audio leaves the phone through Bolo.
- When a card opens, Bolo says a one-sentence summary (and asks the AI's clarifying question first). After saving it says "সেভ করেছি!" ("Saved!"). Code: `features/command/spoken_summary.dart`.
- The voice is chosen per language: Bangla uses `bn-BD`, then `bn-IN`. If the phone has no voice for that language, Bolo stays silent rather than reading Bangla with an English voice, and Settings explains how to install one.
- It can be turned off in Settings. Tapping the orb interrupts speech.

## F16: Contacts (person picker)

- The person field on receivable/payable cards has a contacts button that opens the **system contact picker** (`FlutterContacts.native.showPicker()`).
- **No READ_CONTACTS permission:** Android hands Bolo only the one contact the user picks. Only the display name is used, and it is never sent to the AI.

## F17: Add to phone calendar

- Reminder and task cards have the toggle "ফোনের ক্যালেন্ডারেও যোগ করুন" ("also add to phone calendar"). After saving, Bolo opens the phone's calendar app with the event prefilled (`add_2_calendar`), and the user taps Save there.
- **No calendar permission:** Bolo never reads the calendar.

## F18: Receipt scan

- "রসিদ স্ক্যান" ("scan receipt") on Home and Money opens the camera app, then reads the photo with Google ML Kit text recognition **on the device**, then shows an expense card (confidence 0.6, so the user is asked to check).
- No CAMERA permission is needed (the system camera app takes the photo). **The photo is deleted immediately** after reading.
- Parser (`features/receipt/receipt_parser.dart`, unit-tested):
  1. Prefer the number on a "Grand total / Net payable / সর্বমোট" line.
  2. Otherwise the number on a "Total / মোট" line (not "Sub total").
  3. Otherwise the largest plausible amount, ignoring phone and invoice numbers.

  The merchant is taken from the top lines, and the category is guessed from keywords.
- **Limitation:** ML Kit's on-device recognizer does not support Bangla script. Totals printed in Latin digits work; Bangla-only receipts need manual entry. A future option is sending the photo to a vision AI, which is better for Bangla but costs money and sends the image off the phone, so it needs the user's consent.

## Device access policy

Bolo asks for **purpose-specific** access only, at the moment of use, and prefers system pickers that need no permission. In v1.1 the user asked for a real phone assistant (calls, music, "Bolo" hands-free), so the table grew. Each new item is still tied to one feature the user switches on or asks for by voice.

| Capability | Permission | When it is asked | Status |
|---|---|---|---|
| Microphone (voice input) | `RECORD_AUDIO` | first tap on the robot | ✅ |
| Notifications / exact alarms | `POST_NOTIFICATIONS`, `SCHEDULE_EXACT_ALARM` | first reminder (with an explanation first) | ✅ |
| Voice replies | none | | ✅ |
| Contacts: pick one | none (system picker) | | ✅ |
| **Contacts: find by name** ("rahim ke call koro") | `READ_CONTACTS` | first voice call by name; the search runs on the phone, names are never uploaded | ✅ v1.1 |
| **Place a call** | `CALL_PHONE` | first call; if refused, the dialer opens with the number instead | ✅ v1.1 |
| **Play music / open apps** | none (standard intents; launcher apps visible via `<queries>`) | | ✅ v1.1 |
| **Hands-free wake word ("Bolo")** | `FOREGROUND_SERVICE_MICROPHONE` + permanent notification | only when the user switches it on in Settings | ✅ v1.1 |
| **Appear when called** | `USE_FULL_SCREEN_INTENT`, `SYSTEM_ALERT_WINDOW` (user grants in Android settings) | from the hands-free card | ✅ v1.1 |
| Calendar | none (calendar app intent) | | ✅ |
| Camera (receipts) | none (camera app intent) | | ✅ |
| **SMS (bKash/Nagad transaction SMS)** | `READ_SMS` is a Google Play *restricted* permission | | ❌ Not added. Needs a separate Play policy review |
| Call logs, location, files/photos, accessibility service, "all access" | restricted, or no product purpose | | ❌ Will not be added |

### Hands-free wake word (F19)

- **Engine:** [Vosk](https://alphacephei.com/vosk/) `vosk-model-small-en-us-0.15` (Apache 2.0), fully **offline** on the phone. Audio is processed in memory and dropped; nothing is recorded or sent.
- **Grammar spotting:** the recogniser may only output the name, about 30 common "competitor" words, or `[unk]`, and the name must reach a confidence of 0.6 (Normal), 0.75 (Less) or 0.5 (More).
- **Measured on the PC** (synthetic voices David/Zira, 26 clips): 11/11 wake phrases detected ("Bolo", "Hey Bolo", "Okay Bolo, call mom"), **0/15 false alarms** ("hello", "below", "polo shirt", "bowl of rice", "hollow", "volume", ...). Real voices, accents and noise will differ: test on phones and adjust the sensitivity.
- **Custom names:** any English word in the model's vocabulary works (Bolo, Robi, Mina, Rahim, Jarvis...). Unknown words are rejected in Settings, because they could never be heard.
- **When it hears the name:** it vibrates, wakes the screen and opens Bolo (over the lock screen if locked, in a privacy mode that shows no data). Bolo says "জি, বলুন" and listens. Calls, music and apps require unlocking first. The session ends after 30 s idle, and the listener resumes.
- **Limits (told to users):** does not work when the phone is switched off; uses more battery; Android forbids starting a microphone service at boot, so after a restart the user opens Bolo once.

### Assistant actions (F20)

| Say | Intent | What happens |
|---|---|---|
| "rahim ke call koro", "মাকে ফোন দাও", "01712… e call koro" | `call_contact` | Contacts are searched on the phone (family words: Ammu/Amma/Ma/Mom…). The call card asks "রহিমকে কল করবো?" and listens for হ্যাঁ/না (or a tap). **A call is never placed without a confirmation.** |
| "arijit singh er gaan bajao", "play shape of you" | `play_media` | Android's play-from-search intent (Spotify, YouTube Music…), falling back to a YouTube search |
| "youtube kholo", "open whatsapp" | `open_app` | Opens the best-matching installed app |
| "10 minute pore pani khete mone koriye dio" | `create_reminder` | Relative times are supported |

"Remind me to call X" stays a reminder, not a call.

---

## Ambiguous dates and times

Bangladesh uses **UTC+06:00 all year (no daylight saving)**. The app still uses the IANA zone `Asia/Dhaka` instead of a fixed offset, so any future rule change is handled by the timezone database.

| Phrase | Interpretation | Ambiguous? |
|---|---|---|
| আজ / aaj / today | Dhaka date today | No |
| কাল / kal | **Context-dependent:** "tomorrow" in future-tense sentences, "yesterday" in past-tense ones ("kal khoroch holo" = "spent yesterday"). The AI decides from the verb tense, and if it can't decide it flags the date as `relative_day` ambiguous. | Sometimes |
| পরশু / porshu | The day after tomorrow (or the day before yesterday in past tense; same rule) | Sometimes |
| ৫টায় / 5 tay without সকাল/দুপুর/বিকাল/সন্ধ্যা/রাত (morning/noon/afternoon/evening/night) | `am_pm` ambiguity. The default is the **next future** occurrence between 07:00 and 22:00. | Yes |
| সকাল (morning) 5-11, দুপুর (midday) 12-14, বিকাল (afternoon) 15-17, সন্ধ্যা (evening) 18-19, রাত (night) 20-23 or 0-4 | The time-of-day word fixes AM/PM | No |
| শুক্রবার / Friday | The next Friday (today if today is Friday and the time is still ahead) | No |
| next Friday / আগামী শুক্রবার | Next Friday. If said on Thursday it is ambiguous (tomorrow vs +8 days): flag as `relative_week` | Sometimes |
| ২৫ তারিখ / 25 tarikh | The 25th of this month if still ahead, otherwise next month | No |
| সামনের মাসে / next month (no day) | Date missing, so Bolo asks for one | Yes (`missing_date`) |

**Who does the date maths?** The AI receives today's Dhaka date, the weekday, and a 14-day calendar table in the prompt, and returns `YYYY-MM-DD` plus an ambiguity tag. The **server then re-validates** the result: the date must be real, within ±2 years, and in the future for reminders. The **app recomputes** the final instant with `TZDateTime(Asia/Dhaka, …)`. The model is never asked to produce a UTC timestamp or an offset, so the class of error where an LLM gets timezone arithmetic wrong is eliminated.
