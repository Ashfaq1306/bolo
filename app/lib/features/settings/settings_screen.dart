import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/bangla_digits.dart';
import '../../core/providers.dart';
import '../../core/widgets/depth_card.dart';
import '../../l10n/app_localizations.dart';
import '../assistant/assistant_settings_card.dart';
import '../command/capture_controller.dart';
import '../command/confirmation_sheet.dart';
import '../migration/guest_migration.dart';
import '../records/models.dart';
import '../update/update_prompt.dart';
import '../voice/voice_check_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);
    final registeredUid = ref.watch(registeredUidProvider);
    final user = ref.watch(currentUserProvider);
    final migration = ref.watch(migrationStatusProvider);
    final summaryHour = ref.watch(summaryHourProvider);
    final inbox = ref.watch(inboxItemsProvider).value ?? const [];

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
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.record_voice_over_rounded),
              title: Text(l.voiceReplies),
              value: ref.watch(voiceRepliesProvider),
              onChanged: (v) => ref.read(voiceRepliesProvider.notifier).set(v),
            ),
            if (ref.watch(voiceRepliesProvider))
              FutureBuilder<bool>(
                future: ref.read(voiceReplyProvider).isAvailable(lang),
                builder: (context, snap) => snap.data == false
                    ? Text(l.voiceUnavailable, style: TextStyle(color: theme.colorScheme.error))
                    : const SizedBox.shrink(),
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
                if (h >= 0 && context.mounted) await ensureReminderPermissions(context, ref);
              },
            ),
          ]),
        ),
        const SizedBox(height: 12),
        const AssistantSettingsCard(),
        const SizedBox(height: 12),
        const VoiceCheckCard(),
        const SizedBox(height: 12),
        DepthCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l.account, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            if (registeredUid == null)
              // Account sign-up returns with registered sync (Phase 2). Linking
              // now would hide the guest data, which lives only on this phone.
              Text(l.guestLocalOnly)
            else
              Text(l.accountSecured(user?.email ?? '')),
            if (migration != null) _MigrationLine(migration),
          ]),
        ),
        const SizedBox(height: 12),
        DepthCard(
          child: Row(children: [
            const Icon(Icons.system_update_rounded),
            const SizedBox(width: 12),
            Expanded(
              child: FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snap) => Text(
                  snap.hasData ? l.appVersion(localDigits('${snap.data!.version} (${snap.data!.buildNumber})', lang)) : '',
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ),
            FilledButton.tonal(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final updater = ref.read(appUpdaterProvider);
                final update = await updater.check();
                if (!context.mounted) return;
                if (update == null) {
                  messenger.showSnackBar(SnackBar(content: Text(l.upToDate)));
                } else {
                  await showUpdateDialog(context, updater, update);
                }
              },
              child: Text(l.checkUpdates),
            ),
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
              const Icon(Icons.devices_rounded),
              const SizedBox(width: 8),
              Text(l.devicePowers, style: theme.textTheme.titleMedium),
            ]),
            const SizedBox(height: 8),
            Text(l.devicePowersBody),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              Chip(avatar: const Icon(Icons.mic_rounded, size: 18), label: Text(l.navToday)),
              Chip(avatar: const Icon(Icons.record_voice_over_rounded, size: 18), label: Text(l.voiceReplies.split('(').first.trim())),
              Chip(avatar: const Icon(Icons.contacts_rounded, size: 18), label: Text(l.pickContact)),
              Chip(avatar: const Icon(Icons.edit_calendar_rounded, size: 18), label: Text(l.addToCalendar)),
              Chip(avatar: const Icon(Icons.document_scanner_rounded, size: 18), label: Text(l.scanReceipt)),
              Chip(avatar: const Icon(Icons.notifications_rounded, size: 18), label: Text(l.remindersTitle)),
            ]),
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
}

/// Progress of the one-time move of earlier data onto this phone.
class _MigrationLine extends StatelessWidget {
  const _MigrationLine(this.status);
  final MigrationStatus status;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final text = switch (status.phase) {
      MigrationPhase.notNeeded => null,
      MigrationPhase.running => l.migrationRunning,
      MigrationPhase.cacheOnly => l.migrationCacheOnly,
      MigrationPhase.done => status.copied == 0 ? null : l.migrationDone(localDigits('${status.copied}', lang)),
      MigrationPhase.failed => l.migrationFailed,
    };
    if (text == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(children: [
        Icon(
          status.phase == MigrationPhase.failed ? Icons.error_outline_rounded : Icons.phone_android_rounded,
          size: 18,
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ]),
    );
  }
}
