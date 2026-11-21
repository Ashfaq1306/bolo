import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../core/widgets/depth_card.dart';
import '../../l10n/app_localizations.dart';
import 'assistant_settings.dart';

/// Settings → Assistant: the assistant's name (= wake word), hands-free mode,
/// sensitivity, and the two Android switches that let Bolo appear by itself.
class AssistantSettingsCard extends ConsumerStatefulWidget {
  const AssistantSettingsCard({super.key});
  @override
  ConsumerState<AssistantSettingsCard> createState() => _AssistantSettingsCardState();
}

class _AssistantSettingsCardState extends ConsumerState<AssistantSettingsCard> with WidgetsBindingObserver {
  late final _name = TextEditingController(text: ref.read(assistantNameProvider));
  String? _nameError;
  bool _checking = false;
  bool _overApps = true;
  bool _fullScreen = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshAccess();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _name.dispose();
    super.dispose();
  }

  // Coming back from Android settings: re-check what's allowed.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshAccess();
  }

  Future<void> _refreshAccess() async {
    final device = ref.read(deviceBridgeProvider);
    final over = await device.canAppearOverApps();
    final full = await device.canUseFullScreen();
    if (mounted) {
      setState(() {
        _overApps = over;
        _fullScreen = full;
      });
    }
  }

  Future<void> _saveName() async {
    final l = AppLocalizations.of(context);
    final clean = normalizeAssistantName(_name.text);
    if (clean == null) {
      setState(() => _nameError = l.assistantNameInvalid);
      return;
    }
    setState(() => _checking = true);
    // The offline recogniser can only hear words it knows.
    final known = await ref.read(deviceBridgeProvider).wakeKnowsName(clean.toLowerCase());
    if (!mounted) return;
    setState(() => _checking = false);
    if (!known) {
      setState(() => _nameError = l.assistantNameUnknown);
      return;
    }
    await ref.read(assistantNameProvider.notifier).set(clean);
    _name.text = clean;
    setState(() => _nameError = null);
    await ref.read(wakeSyncProvider)();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.saved)));
  }

  Future<void> _toggleHandsFree(bool on) async {
    final device = ref.read(deviceBridgeProvider);
    if (on) {
      if (!await device.requestPermission('microphone')) return;
      await device.requestPermission('notifications');
    }
    await ref.read(handsFreeProvider.notifier).set(on);
    await ref.read(wakeSyncProvider)();
    await _refreshAccess();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final name = ref.watch(assistantNameProvider);
    final shown = assistantDisplayName(name, lang);
    final handsFree = ref.watch(handsFreeProvider);
    final sensitivity = ref.watch(wakeSensitivityProvider);
    final device = ref.read(deviceBridgeProvider);

    return DepthCard(
      accent: BoloColors.teal,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.smart_toy_rounded),
          const SizedBox(width: 8),
          Text(l.assistantTitle, style: theme.textTheme.titleMedium),
        ]),
        const SizedBox(height: 12),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: TextField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              maxLength: 20,
              decoration: InputDecoration(
                labelText: l.assistantName,
                helperText: l.assistantNameHint,
                helperMaxLines: 2,
                errorText: _nameError,
                errorMaxLines: 3,
              ),
              onSubmitted: (_) => _saveName(),
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _checking
                ? const SizedBox.square(dimension: 40, child: Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator(strokeWidth: 2)))
                : IconButton.filledTonal(onPressed: _saveName, icon: const Icon(Icons.check_rounded), tooltip: l.save),
          ),
        ]),
        const SizedBox(height: 4),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          secondary: const Icon(Icons.hearing_rounded),
          title: Text(l.handsFree(shown)),
          subtitle: Text(l.handsFreeBody(shown)),
          value: handsFree,
          onChanged: _toggleHandsFree,
        ),
        if (handsFree) ...[
          Text(l.sensitivity, style: theme.textTheme.labelLarge),
          const SizedBox(height: 6),
          SegmentedButton<int>(
            segments: [
              ButtonSegment(value: 0, label: Text(l.sensLow)),
              ButtonSegment(value: 1, label: Text(l.sensNormal)),
              ButtonSegment(value: 2, label: Text(l.sensHigh)),
            ],
            selected: {sensitivity},
            onSelectionChanged: (s) async {
              await ref.read(wakeSensitivityProvider.notifier).set(s.first);
              await ref.read(wakeSyncProvider)();
            },
          ),
          const SizedBox(height: 8),
          // Android needs these two switches for Bolo to pop up by itself.
          _AccessRow(
            icon: Icons.lock_open_rounded,
            label: l.allowLockScreen,
            allowed: _fullScreen,
            onAllow: device.openFullScreenSettings,
            allowText: l.allowButton,
            allowedText: l.allowedLabel,
          ),
          _AccessRow(
            icon: Icons.layers_rounded,
            label: l.allowOverApps,
            allowed: _overApps,
            onAllow: device.openAppearOverAppsSettings,
            allowText: l.allowButton,
            allowedText: l.allowedLabel,
          ),
          const SizedBox(height: 8),
          Text(l.handsFreeLimits, style: theme.textTheme.bodySmall),
        ],
        const SizedBox(height: 8),
        Text(l.assistantCanDo(shown), style: theme.textTheme.bodySmall),
      ]),
    );
  }
}

class _AccessRow extends StatelessWidget {
  const _AccessRow({
    required this.icon,
    required this.label,
    required this.allowed,
    required this.onAllow,
    required this.allowText,
    required this.allowedText,
  });
  final IconData icon;
  final String label;
  final bool allowed;
  final Future<void> Function() onAllow;
  final String allowText, allowedText;

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon),
        title: Text(label),
        trailing: allowed
            ? Chip(avatar: const Icon(Icons.check_rounded, size: 18), label: Text(allowedText))
            : FilledButton.tonal(onPressed: onAllow, child: Text(allowText)),
      );
}
