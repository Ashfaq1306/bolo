import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/bangla_digits.dart';
import '../../core/providers.dart';
import '../../core/widgets/depth_card.dart';
import '../../l10n/app_localizations.dart';
import '../command/capture_controller.dart';
import '../records/models.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);
    final user = ref.watch(authStateProvider).value;
    final summaryHour = ref.watch(summaryHourProvider);
    final inbox = ref.watch(inboxItemsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: Text(l.settingsTitle), backgroundColor: Colors.transparent),
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 0, 16, 32), children: [
        DepthCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l.language, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'bn', label: Text('বাংলা')),
                ButtonSegment(value: 'en', label: Text('English')),
              ],
              selected: {lang},
              onSelectionChanged: (s) => ref.read(localeProvider.notifier).set(s.first),
            ),
            const SizedBox(height: 16),
            Text(l.speechLanguage, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'bn-BD', label: Text('বাংলা (bn-BD)')),
                ButtonSegment(value: 'en-US', label: Text('English')),
              ],
              selected: {ref.watch(speechLocaleProvider)},
              onSelectionChanged: (s) => ref.read(speechLocaleProvider.notifier).set(s.first),
            ),
            const SizedBox(height: 16),
            Text(l.summaryTime, style: theme.textTheme.titleMedium),
            DropdownButton<int>(
              value: summaryHour,
              isExpanded: true,
              items: [
                DropdownMenuItem(value: -1, child: Text(l.off)),
                for (final h in [7, 8, 9, 12, 18, 19, 20, 21, 22, 23])
                  DropdownMenuItem(value: h, child: Text(localDigits('${h.toString().padLeft(2, '0')}:00', lang))),
              ],
              onChanged: (h) async {
                if (h == null) return;
                await ref.read(summaryHourProvider.notifier).set(h);
                if (h >= 0) await ref.read(reminderSchedulerProvider).requestPermissions();
              },
            ),
          ]),
        ),
        const SizedBox(height: 12),
        DepthCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l.account, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            if (user == null || user.isAnonymous) ...[
              Text(l.anonymousWarning),
              const SizedBox(height: 8),
              FilledButton.tonalIcon(
                onPressed: () => _linkEmail(context, ref),
                icon: const Icon(Icons.lock_rounded),
                label: Text(l.secureAccount),
              ),
            ] else
              Text(l.accountSecured(user.email ?? '')),
          ]),
        ),
        const SizedBox(height: 12),
        DepthCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l.inbox, style: theme.textTheme.titleMedium),
            if (inbox.isEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Text(l.inboxEmpty)),
            for (final item in inbox)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(item.fromVoice ? Icons.mic_rounded : Icons.keyboard_rounded),
                title: Text(item.text),
                trailing: FilledButton.tonal(
                  onPressed: () async {
                    await ref.read(inboxStoreProvider).remove(item);
                    ref.invalidate(inboxItemsProvider);
                    await ref.read(captureControllerProvider.notifier).submit(
                          item.text,
                          source: item.fromVoice ? RecordSource.voice : RecordSource.text,
                        );
                  },
                  child: Text(l.process),
                ),
              ),
          ]),
        ),
        const SizedBox(height: 12),
        DepthCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.shield_rounded),
              const SizedBox(width: 8),
              Text(l.privacy, style: theme.textTheme.titleMedium),
            ]),
            const SizedBox(height: 8),
            Text(l.privacyBody),
          ]),
        ),
      ]),
    );
  }

  Future<void> _linkEmail(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final email = TextEditingController();
    final password = TextEditingController();
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l.secureAccount),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: InputDecoration(labelText: l.email)),
          const SizedBox(height: 8),
          TextField(controller: password, obscureText: true, decoration: InputDecoration(labelText: l.password)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(l.cancel)),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(l.save)),
        ],
      ),
    );
    if (ok == true) {
      try {
        await ref.read(authServiceProvider).linkEmail(email.text, password.text);
        ref.invalidate(authStateProvider);
        messenger.showSnackBar(SnackBar(content: Text(l.saved)));
      } on FirebaseAuthException catch (e) {
        messenger.showSnackBar(SnackBar(content: Text(e.message ?? e.code)));
      }
    }
    email.dispose();
    password.dispose();
  }
}
