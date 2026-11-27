# 2. User journeys

Each journey lists the **happy path** first, followed by the **edge cases** the app must handle. "Card" means the confirmation card from [03 § F4](03-feature-specifications.md#f4-confirmation-card).

---

## J1: First launch (zero friction)

1. Nusrat installs Bolo and opens it. A short Bangla welcome reads: *"বলুন, আমি মনে রাখব"* ("Speak, and I'll remember").
2. Bolo signs her in **anonymously** in the background, with no form. A one-line privacy note says what is stored, plus a "learn more" link.
3. Bolo asks for microphone permission **only when she first taps the orb**, not at launch. It asks for notification permission the first time she saves a reminder.
4. Home shows the 3D orb, a greeting for the current Dhaka time (শুভ সকাল / শুভ সন্ধ্যা), and the Today summary.

Edge cases
- **No internet on first launch** *(not met by the current code: the app stops at a sign-in error. Fixed by Phase 1, see [ADR-11](adr/0011-guest-data-local-only.md))*: anonymous sign-in fails, so Bolo shows "offline, your data will be saved on this phone" and retries later. (Firestore needs a signed-in user before it can write; see the risk register.)
- **Microphone denied:** typed input stays fully usable, and a banner explains how to enable the mic in Settings.

## J2: Voice reminder (Bangla)

1. Rafiq taps the orb and says: *"কাল সকাল ১০টায় মনে করিয়ে দিও দোকানের ভাড়া দিতে হবে"* ("remind me tomorrow at 10 am to pay the shop rent").
2. The orb pulses with his voice and the live transcript appears.
3. He stops talking. After about 1.5 s of silence, recognition ends and the orb switches to its "thinking" state.
4. The server returns `create_reminder` with title *দোকানের ভাড়া দেওয়া*, at tomorrow 10:00 Asia/Dhaka.
5. The card shows **"রিমাইন্ডার · কাল (শুক্রবার, ২১ নভেম্বর) সকাল ১০:০০"** with Save / Edit.
6. He taps Save. The reminder is stored, a local notification is scheduled, and a snackbar offers "Undo".
7. The next day at 10:00, the notification fires even if his phone has no data.

Edge cases
- **"৫টায়" with no সকাল/বিকাল (morning/afternoon):** the time is ambiguous, so the card asks *"সকাল ৫টা নাকি বিকাল ৫টা?"* ("5 am or 5 pm?") and offers two chips, with a sensible default preselected (the next future occurrence). See [03 § Ambiguous dates](03-feature-specifications.md#ambiguous-dates-and-times).
- **"পরশু" (the day after tomorrow) said at 00:30:** "tomorrow" and "today" are always relative to the Dhaka date, and the card displays the exact date to remove doubt.
- **A time already in the past ("today at 9" said at 11):** the card warns and suggests tomorrow.

## J3: Expense in mixed language (financial, so confirmation is mandatory)

1. Shirin says: *"aaj lunch e 350 taka khoroch holo"* ("spent 350 taka on lunch today").
2. The server returns `add_expense` with amount 350 BDT, category `food`, note "lunch", date today.
3. The card shows **৳৩৫০ · খাবার · আজ**, with a bold **Confirm** button. There is no auto-save and no "Undo" shortcut in place of confirmation.
4. She taps Confirm. The expense is saved and today's spending total updates.

Edge cases
- **Amount unclear ("tin sho pochash" vs "350"):** both spoken numbers and Bangla digits are normalised server-side and then validated client-side, and the card always shows the amount large enough to check.
- **No amount detected:** the card opens with the amount field focused and empty, and the Confirm button is disabled until a valid amount is entered.
- **Amount above ৳10,00,000 (10 lakh):** an extra "Are you sure?" step guards against an STT error adding zeros.

## J4: Money receivable / payable

1. Nusrat says: *"Karim amar kache 2000 taka pay, next Friday dibe"* ("Karim owes me 2,000 taka and will pay next Friday").
2. The server returns `add_receivable` with person Karim, amount 2,000, due date next Friday.
3. The card shows: **"করিম আপনাকে দেবে ৳২,০০০ · শুক্রবার, ২৮ নভেম্বর"** ("Karim will give you ৳2,000"). A direction toggle (আমি পাব ⇄ আমি দেব, "I'll receive / I'll pay") is prominent, because direction errors are the most damaging mistake in a ledger.
4. She taps Confirm. Optionally, the app offers to add a reminder on the due date.
5. Later she says *"Karim taka diye diyeche"* ("Karim has paid"). The server returns `settle_ledger`, the app finds open entries for Karim, and the card lists them to pick from. She confirms, and the entry is marked settled.

Edge cases
- **Two people called Karim, or several open entries:** the user must pick one. Bolo never guesses which record to settle.
- **"Next Friday" said on a Thursday:** this is ambiguous (tomorrow, or in 8 days?). The card shows the chosen date and offers the alternative.

## J5: Task with deadline

1. *"CSE215 assignment submit korte hobe 25 tarikh er moddhe, ek din age mone koriye dio"* ("I have to submit the CSE215 assignment by the 25th; remind me a day before").
2. The server returns `create_task` with title "CSE215 assignment submit", due the 25th of this month (or next month if the 25th has passed), and a reminder offset of 1 day before.
3. The card shows the task, the deadline, and the reminder. She saves.

## J6: Daily summary

1. At the chosen time (default 21:00 Dhaka), a local notification says: *"আজকের সারাংশ: ২টি কাজ বাকি, খরচ ৳৮৫০"* ("Today's summary: 2 tasks left, ৳850 spent").
2. Tapping it opens the Today screen. The summary is computed **on the phone** from local data, with no AI call and no cost.
3. Saying *"aajker summary dao"* ("give me today's summary") gives `query_summary` and opens the same screen.

## J7: Offline capture

1. Rafiq is offline and taps the orb. On-device STT may still work, depending on the device and the installed language pack.
2. The AI parse cannot run, so Bolo saves the text to the **Inbox** with "will process when online" and offers manual entry right away.
3. When the network returns, the Inbox shows a "Process now" button. Bolo does not upload automatically in the background, so the user stays in control of their data and their mobile-data cost.

## J8: Upgrade account and use a second phone

1. Settings → "Secure your data" → enter email and password. The anonymous account is **linked**, so its UID and data stay the same.
2. On a new phone, the user signs in with the same email, and Firestore syncs the records down. Reminders are re-scheduled locally from the synced records.

## J9: Delete my data

1. Settings → Privacy → "Delete all my data".
2. A double confirmation (type "DELETE" or tap a long-press button) leads to a server function that deletes all of `users/{uid}/**` and then the Auth account. Local notifications are cancelled and the local cache is cleared.
