import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/theme.dart';
import '../../l10n/app_localizations.dart';
import '../command/parsed_command.dart';
import '../voice/face_mood.dart';
import '../voice/orb_face.dart';
import 'assistant_settings.dart';
import 'device_bridge.dart';

/// Runs a phone action the user asked for: call someone, play music, open an app.
///
/// Over the lock screen Bolo first asks the user to unlock (so nobody can use
/// a locked phone to call contacts or open apps).
Future<void> runAssistantAction(BuildContext context, WidgetRef ref, ParsedCommand c) async {
  final l = AppLocalizations.of(context);
  final lang = ref.read(localeProvider).languageCode;
  final device = ref.read(deviceBridgeProvider);
  final mood = ref.read(faceMoodProvider.notifier);
  final session = ref.read(wakeSessionProvider.notifier);
  Future<void> say(String text) async {
    if (ref.read(voiceRepliesProvider)) await ref.read(voiceReplyProvider).speak(text, languageCode: lang);
  }

  session.touch();
  if (await device.isLocked() && !await device.requestUnlock()) {
    mood.flash(FaceExpression.confused);
    await say(l.needUnlock);
    return;
  }

  switch (c.intent) {
    case CommandIntent.playMedia:
      mood.flash(FaceExpression.happy);
      await say(l.speakPlay(c.title));
      final how = await device.playMedia(c.title);
      if (how == 'none') {
        mood.flash(FaceExpression.confused);
        await say(l.playFailed);
      }
      await session.end();
    case CommandIntent.openApp:
      final opened = await device.openApp(c.title);
      if (opened == null) {
        mood.flash(FaceExpression.confused);
        await say(l.appNotFound(c.title));
      } else {
        mood.flash(FaceExpression.happy);
        await session.end();
      }
    case CommandIntent.callContact:
      if (!context.mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        useSafeArea: true,
        builder: (_) => CallSheet(person: c.person),
      );
      await session.end();
    default:
      break;
  }
}

/// A person/number the user might mean.
class CallCandidate {
  const CallCandidate(this.name, this.number);
  final String name;
  final String number;
}

/// Family words people say instead of a contact name.
const _aliases = <String, List<String>>{
  'mom': ['Ammu', 'Amma', 'Ma', 'Maa', 'Mom', 'Mother', 'আম্মু', 'আম্মা', 'মা'],
  'dad': ['Abbu', 'Abba', 'Baba', 'Dad', 'Father', 'আব্বু', 'আব্বা', 'বাবা'],
};

List<String> searchTermsFor(String person) {
  final p = person.trim().toLowerCase();
  for (final group in _aliases.values) {
    if (group.any((a) => a.toLowerCase() == p)) return [person.trim(), ...group.where((a) => a.toLowerCase() != p)];
  }
  return [person.trim()];
}

bool _isNumber(String s) => RegExp(r'^\+?[\d\s-]{6,}$').hasMatch(s.trim());

/// Bottom sheet: find who to call, confirm (tap, or say "yes"), then call.
class CallSheet extends ConsumerStatefulWidget {
  const CallSheet({super.key, required this.person});
  final String person;
  @override
  ConsumerState<CallSheet> createState() => _CallSheetState();
}

class _CallSheetState extends ConsumerState<CallSheet> {
  List<CallCandidate>? _candidates;
  bool _noPermission = false;
  bool _listening = false;
  StreamSubscription<dynamic>? _sub;
  final _number = TextEditingController();

  @override
  void initState() {
    super.initState();
    _search();
  }

  @override
  void dispose() {
    _sub?.cancel();
    ref.read(speechServiceProvider).cancel();
    _number.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final person = widget.person.trim();
    if (person.isEmpty) {
      setState(() => _candidates = const []);
      return;
    }
    if (_isNumber(person)) {
      setState(() => _candidates = [CallCandidate(person, person)]);
      _askByVoice();
      return;
    }
    final status = await FlutterContacts.permissions.request(PermissionType.read);
    if (status != PermissionStatus.granted && status != PermissionStatus.limited) {
      setState(() {
        _noPermission = true;
        _candidates = const [];
      });
      return;
    }
    final found = <CallCandidate>[];
    final seen = <String>{};
    for (final term in searchTermsFor(person)) {
      final contacts = await FlutterContacts.getAll(
        properties: {ContactProperty.phone},
        filter: ContactFilter.name(term),
        limit: 15,
      );
      for (final c in contacts) {
        for (final p in c.phones) {
          final key = p.number.replaceAll(RegExp(r'[^\d+]'), '');
          if (key.isEmpty || !seen.add(key)) continue;
          found.add(CallCandidate(c.displayName ?? term, p.number));
        }
      }
      if (found.isNotEmpty) break;
    }
    if (!mounted) return;
    setState(() => _candidates = found);
    if (found.length == 1) _askByVoice();
  }

  /// "Call Rahim?" then listen briefly for yes/no, so it works hands-free.
  Future<void> _askByVoice() async {
    final c = _candidates?.firstOrNull;
    if (c == null || !ref.read(voiceRepliesProvider)) return;
    final l = AppLocalizations.of(context);
    final lang = ref.read(localeProvider).languageCode;
    await ref.read(voiceReplyProvider).speak(l.callConfirmQuestion(c.name), languageCode: lang);
    if (!mounted) return;
    final speech = ref.read(speechServiceProvider);
    if (!await speech.init()) return;
    setState(() => _listening = true);
    _sub = speech.states.listen((s) {
      final text = s.text.toLowerCase();
      if (RegExp(r'\b(na|no|nah|thak|cancel|stop)\b|না|থাক|বাদ').hasMatch(text)) {
        _sub?.cancel();
        speech.cancel();
        if (mounted) Navigator.pop(context);
      } else if (RegExp(r'\b(ha|haa|hya|hyan|yes|yeah|ok|okay|koro|call|di|dao)\b|হ্যাঁ|হা|জি|করো|কল|দাও').hasMatch(text)) {
        _sub?.cancel();
        speech.cancel();
        _call(c);
      } else if (!s.listening && s.isFinal) {
        if (mounted) setState(() => _listening = false);
      }
    });
    await speech.start(localeId: ref.read(speechLocaleProvider));
    Timer(const Duration(seconds: 7), () {
      if (mounted && _listening) {
        speech.cancel();
        setState(() => _listening = false);
      }
    });
  }

  Future<void> _call(CallCandidate c) async {
    final device = ref.read(deviceBridgeProvider);
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    // First call: Android asks "Allow Bolo to make phone calls?". If the user
    // says no, the dialer opens with the number instead.
    await device.requestPermission('phone');
    final outcome = await device.callNumber(c.number);
    ref.read(faceMoodProvider.notifier).flash(outcome == CallOutcome.failed || outcome == CallOutcome.invalid
        ? FaceExpression.confused
        : FaceExpression.happy);
    if (outcome == CallOutcome.dialer) messenger.showSnackBar(SnackBar(content: Text(l.callDialerNote)));
    if (mounted) Navigator.pop(context);
  }

  Future<void> _pickFromContacts() async {
    final c = await FlutterContacts.native.showPicker(properties: {ContactProperty.phone});
    if (c == null || !mounted) return;
    setState(() => _candidates = [
          for (final p in c.phones) CallCandidate(c.displayName ?? '', p.number),
        ]);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final candidates = _candidates;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          const Icon(Icons.call_rounded, color: BoloColors.teal),
          const SizedBox(width: 8),
          Expanded(child: Text(l.callWho, style: theme.textTheme.titleLarge)),
          if (_listening) const Icon(Icons.mic_rounded, color: BoloColors.pink),
        ]),
        const SizedBox(height: 12),
        if (candidates == null)
          const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()))
        else ...[
          if (candidates.isEmpty)
            Text(_noPermission ? l.contactsPermissionNeeded : l.callNoMatch(widget.person)),
          for (final c in candidates.take(6))
            Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person_rounded)),
                title: Text(c.name),
                subtitle: Text(c.number),
                trailing: FilledButton.icon(
                  onPressed: () => _call(c),
                  icon: const Icon(Icons.call_rounded),
                  label: Text(l.callButton),
                ),
              ),
            ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _pickFromContacts,
            icon: const Icon(Icons.contacts_rounded),
            label: Text(l.pickContact),
          ),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: TextField(
                controller: _number,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(hintText: l.callTypeNumber, prefixIcon: const Icon(Icons.dialpad_rounded)),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: () {
                final n = _number.text.trim();
                if (_isNumber(n)) _call(CallCandidate(n, n));
              },
              icon: const Icon(Icons.call_rounded),
            ),
          ]),
        ],
      ]),
    );
  }
}
