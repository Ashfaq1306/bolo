import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dhaka_time.dart';
import '../../core/labels.dart';
import '../../core/money.dart';
import '../../core/providers.dart';
import '../../core/theme.dart';
import '../../l10n/app_localizations.dart';
import '../records/models.dart';
import '../reminders/calendar_export.dart';
import '../voice/face_mood.dart';
import '../voice/orb_face.dart';
import 'command_saver.dart';
import 'parsed_command.dart';

/// Opens the confirmation card. Returns what was saved (or null if cancelled)
/// and shows the "Saved / Undo" snackbar.
Future<void> showConfirmationSheet(BuildContext context, WidgetRef ref, ParsedCommand proposal) async {
  final messenger = ScaffoldMessenger.of(context);
  final l = AppLocalizations.of(context);
  final result = await showModalBottomSheet<(SaveResult, bool)>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => ConfirmationSheet(proposal: proposal),
  );
  if (result == null) return;
  final (saved, financial) = result;
  // Bolo smiles and says "saved".
  ref.read(faceMoodProvider.notifier).flash(FaceExpression.happy);
  if (ref.read(voiceRepliesProvider)) {
    final lang = ref.read(localeProvider).languageCode;
    ref.read(voiceReplyProvider).speak(l.speakSaved, languageCode: lang);
  }
  messenger.showSnackBar(SnackBar(
    content: Text(l.saved),
    duration: const Duration(seconds: 5),
    // Undo is offered only for non-financial records (docs/03 § F4).
    action: financial
        ? null
        : SnackBarAction(label: l.undo, onPressed: () => ref.read(commandSaverProvider)?.undo(saved)),
  ));
}

class ConfirmationSheet extends ConsumerStatefulWidget {
  const ConfirmationSheet({super.key, required this.proposal});
  final ParsedCommand proposal;

  @override
  ConsumerState<ConfirmationSheet> createState() => _ConfirmationSheetState();
}

class _ConfirmationSheetState extends ConsumerState<ConfirmationSheet> {
  late ParsedCommand _draft = widget.proposal;
  late final _title = TextEditingController(text: widget.proposal.title);
  late final _person = TextEditingController(text: widget.proposal.person);
  late final _amount = TextEditingController(
    text: widget.proposal.amountPoisha == null ? '' : _plainAmount(widget.proposal.amountPoisha!),
  );
  String? _settleId;
  bool _saving = false;
  bool _addToCalendar = false;

  /// Opens the phone's own contact picker. No contacts permission is needed:
  /// Bolo only receives the one contact the user taps.
  Future<void> _pickContact() async {
    try {
      final contact = await FlutterContacts.native.showPicker();
      final name = contact?.displayName?.trim();
      if (name != null && name.isNotEmpty) {
        setState(() {
          _person.text = name.length > 80 ? name.substring(0, 80) : name;
          _sync();
        });
      }
    } catch (e) {
      debugPrint('Contact picker failed: $e');
    }
  }

  static String _plainAmount(int poisha) =>
      poisha % 100 == 0 ? '${poisha ~/ 100}' : (poisha / 100).toStringAsFixed(2);

  static const _choosable = [
    CommandIntent.createReminder,
    CommandIntent.createTask,
    CommandIntent.addExpense,
    CommandIntent.addReceivable,
    CommandIntent.addPayable,
    CommandIntent.settleLedger,
  ];

  @override
  void dispose() {
    _title.dispose();
    _person.dispose();
    _amount.dispose();
    super.dispose();
  }

  void _sync() {
    final poisha = Money.tryParsePoisha(_amount.text);
    _draft = _draft.copyWith(
      title: _title.text,
      person: _person.text,
      amountPoisha: poisha,
      clearAmount: poisha == null,
    );
  }

  Future<void> _pickDate() async {
    final lang = Localizations.localeOf(context).languageCode;
    final now = DhakaTime.toDhaka(ref.read(clockProvider)());
    final current = DhakaTime.parseIsoDate(_draft.date);
    final picked = await showDatePicker(
      context: context,
      locale: Locale(lang),
      initialDate: current == null ? now : DateTime(current.year, current.month, current.day),
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
    );
    if (picked == null) return;
    final iso = '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    setState(() => _draft = _draft.copyWith(date: iso, ambiguity: Ambiguity.none));
  }

  Future<void> _pickTime() async {
    final hm = DhakaTime.parseHm(_draft.time);
    final picked = await showTimePicker(
      context: context,
      initialTime: hm == null ? const TimeOfDay(hour: 9, minute: 0) : TimeOfDay(hour: hm.hour, minute: hm.minute),
    );
    if (picked == null) return;
    final text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    setState(() => _draft = _draft.copyWith(time: text, ambiguity: Ambiguity.none));
  }

  Future<void> _save() async {
    _sync();
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final saver = ref.read(commandSaverProvider);
    if (saver == null) return;

    // Extra check for very large amounts: a classic STT error adds zeros.
    final amount = _draft.amountPoisha;
    if (_draft.intent.isFinancial && amount != null && amount > Money.largeAmountPoisha) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: Text(l.largeAmountTitle),
          content: Text(l.largeAmountBody(Money.format(amount, languageCode: lang))),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: Text(l.cancel)),
            FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(l.confirm)),
          ],
        ),
      );
      if (ok != true) return;
    }

    setState(() => _saving = true);
    try {
      // userConfirmed is true ONLY because this runs from a button the user tapped.
      final result = await saver.save(_draft, userConfirmed: true, settleEntryId: _settleId);
      final at = _draft.instant;
      if (_addToCalendar && at != null) {
        await addToPhoneCalendar(title: _draft.title.trim(), start: at, description: 'বলো · Bolo');
      }
      if (_draft.intent == CommandIntent.createReminder || _draft.remindBefore) {
        await ref.read(reminderSchedulerProvider).requestPermissions();
      }
      if (mounted) Navigator.pop(context, (result, _draft.intent.isFinancial));
    } on DraftInvalid {
      setState(() {});
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);
    final now = ref.watch(clockProvider)();
    _sync();
    final problems = validateDraft(_draft, now).where((p) => p != DraftProblem.notSavable).toList();
    final canSave = _draft.intent.isSavable &&
        problems.isEmpty &&
        (_draft.intent != CommandIntent.settleLedger || _settleId != null) &&
        !_saving;
    final financial = _draft.intent.isFinancial;
    final ambiguityText = l.ambiguity(_draft.ambiguity);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_draft.transcript.isNotEmpty) ...[
              Text('${l.heard}: “${_draft.transcript}”',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: 12),
            ],
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final i in _choosable)
                  ChoiceChip(
                    avatar: Icon(intentIcon(i), size: 18),
                    label: Text(l.intent(i)),
                    selected: _draft.intent == i,
                    onSelected: (_) => setState(() => _draft = _draft.copyWith(intent: i)),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (_draft.onDevice)
              _Banner(icon: Icons.phone_android_rounded, color: BoloColors.violet, text: l.offlineParserNote),
            if (ambiguityText != null || _draft.clarification != null)
              _Banner(
                icon: Icons.help_rounded,
                color: BoloColors.amber,
                text: _draft.clarification ?? ambiguityText!,
                child: _draft.alternatives.isEmpty
                    ? null
                    : Wrap(spacing: 8, children: [
                        for (final alt in [
                          // The AI's main interpretation first, then its alternatives.
                          if (widget.proposal.date != null)
                            DateTimeOption(date: widget.proposal.date!, time: widget.proposal.time),
                          ..._draft.alternatives,
                        ])
                          if (DhakaTime.combine(alt.date, alt.time) case final at?)
                            ChoiceChip(
                              label: Text('${DhakaTime.formatDate(at, lang)} · ${DhakaTime.formatTime(at, lang)}'),
                              selected: _draft.date == alt.date && _draft.time == alt.time,
                              onSelected: (_) => setState(() => _draft = _draft.copyWith(date: alt.date, time: alt.time, clearTime: alt.time == null)),
                            ),
                      ]),
              ),
            ..._fields(l, lang),
            if (financial) ...[
              const SizedBox(height: 8),
              _Banner(icon: Icons.verified_user_rounded, color: BoloColors.teal, text: l.financialNote),
            ],
            for (final p in problems)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text('• ${l.problem(p)}', style: TextStyle(color: theme.colorScheme.error)),
              ),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel))),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: canSave ? _save : null,
                  icon: Icon(financial ? Icons.verified_rounded : Icons.check_rounded),
                  label: Text(financial ? l.confirm : l.save),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  List<Widget> _fields(AppLocalizations l, String lang) {
    final theme = Theme.of(context);
    final at = _draft.instant;
    Widget gap() => const SizedBox(height: 12);

    Widget dateTimeRow({bool withTime = true}) => Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.event_rounded),
              label: Text(_draft.date == null || at == null ? l.pickDate : DhakaTime.formatDate(at, lang), overflow: TextOverflow.ellipsis),
            ),
          ),
          if (withTime) ...[
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickTime,
                icon: const Icon(Icons.schedule_rounded),
                label: Text(_draft.time == null || at == null ? l.pickTime : DhakaTime.formatTime(at, lang)),
              ),
            ),
          ],
        ]);

    Widget titleField(String label) => TextField(
          controller: _title,
          decoration: InputDecoration(labelText: label),
          maxLength: 200,
          onChanged: (_) => setState(_sync),
        );

    Widget amountField() => TextField(
          controller: _amount,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            labelText: l.fieldAmount,
            prefixText: '৳ ',
            helperText: _draft.amountPoisha == null ? null : Money.format(_draft.amountPoisha!, languageCode: lang),
          ),
          onChanged: (_) => setState(_sync),
        );

    Widget personField() => TextField(
          controller: _person,
          decoration: InputDecoration(
            labelText: l.fieldPerson,
            prefixIcon: const Icon(Icons.person_rounded),
            suffixIcon: IconButton(
              tooltip: l.pickContact,
              icon: const Icon(Icons.contacts_rounded),
              onPressed: _pickContact,
            ),
          ),
          maxLength: 80,
          onChanged: (_) => setState(_sync),
        );

    Widget calendarToggle() => SwitchListTile(
          contentPadding: EdgeInsets.zero,
          secondary: const Icon(Icons.edit_calendar_rounded),
          title: Text(l.addToCalendar),
          value: _addToCalendar && _draft.date != null,
          onChanged: _draft.date == null ? null : (v) => setState(() => _addToCalendar = v),
        );

    switch (_draft.intent) {
      case CommandIntent.createReminder:
        return [
          titleField(l.fieldTitle),
          dateTimeRow(),
          calendarToggle(),
          gap(),
          Wrap(spacing: 8, children: [
            for (final r in ReminderRepeat.values)
              ChoiceChip(
                label: Text(l.repeat(r)),
                selected: _draft.repeat == r,
                onSelected: (_) => setState(() => _draft = _draft.copyWith(repeat: r)),
              ),
          ]),
        ];
      case CommandIntent.createTask:
        return [
          titleField(l.fieldTitle),
          dateTimeRow(),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l.fieldRemindBefore),
            value: _draft.remindBefore,
            onChanged: _draft.date == null
                ? null
                : (v) => setState(() => _draft = _draft.copyWith(reminderOffsetMinutes: v ? 1440 : 0)),
          ),
          calendarToggle(),
        ];
      case CommandIntent.addExpense:
        return [
          amountField(),
          gap(),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final c in ExpenseCategory.values)
              ChoiceChip(
                avatar: Icon(categoryIcon(c), size: 18),
                label: Text(l.category(c)),
                selected: _draft.category == c,
                onSelected: (_) => setState(() => _draft = _draft.copyWith(category: c)),
              ),
          ]),
          gap(),
          titleField(l.fieldNote),
          dateTimeRow(withTime: false),
        ];
      case CommandIntent.addReceivable || CommandIntent.addPayable:
        final receivable = _draft.intent == CommandIntent.addReceivable;
        return [
          // Direction is the most damaging thing to get wrong: big, iconic, coloured.
          SegmentedButton<CommandIntent>(
            segments: [
              ButtonSegment(value: CommandIntent.addReceivable, icon: const Icon(Icons.call_received_rounded), label: Text(l.intentReceivable)),
              ButtonSegment(value: CommandIntent.addPayable, icon: const Icon(Icons.call_made_rounded), label: Text(l.intentPayable)),
            ],
            selected: {_draft.intent},
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: (receivable ? BoloColors.receive : BoloColors.pay).withValues(alpha: 0.25),
            ),
            onSelectionChanged: (s) => setState(() => _draft = _draft.copyWith(intent: s.first)),
          ),
          gap(),
          personField(),
          amountField(),
          gap(),
          titleField(l.fieldNote),
          dateTimeRow(withTime: false),
        ];
      case CommandIntent.settleLedger:
        final entries = (ref.watch(openLedgerProvider).value ?? const <LedgerEntry>[])
            .where((e) => _person.text.trim().isEmpty ||
                e.person.toLowerCase().contains(_person.text.trim().toLowerCase()))
            .toList();
        return [
          personField(),
          Text(l.pickEntryToSettle, style: theme.textTheme.titleSmall),
          if (entries.isEmpty) Padding(padding: const EdgeInsets.all(8), child: Text(l.noOpenEntries)),
          RadioGroup<String>(
            groupValue: _settleId,
            onChanged: (v) => setState(() => _settleId = v),
            child: Column(children: [
              for (final e in entries)
                RadioListTile<String>(
                  value: e.id,
                  title: Text('${e.person} · ${Money.format(e.amountPoisha, languageCode: lang)}'),
                  subtitle: Text(e.direction == LedgerDirection.receivable ? l.intentReceivable : l.intentPayable),
                ),
            ]),
          ),
        ];
      case CommandIntent.querySummary || CommandIntent.unknown:
        return [Text(l.notUnderstood, style: theme.textTheme.bodyMedium)];
    }
  }
}

extension on ParsedCommand {
  bool get remindBefore => (reminderOffsetMinutes ?? 0) > 0;
}

class _Banner extends StatelessWidget {
  const _Banner({required this.icon, required this.color, required this.text, this.child});
  final IconData icon;
  final Color color;
  final String text;
  final Widget? child;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(text)),
          ]),
          if (child != null) ...[const SizedBox(height: 8), child!],
        ]),
      );
}
