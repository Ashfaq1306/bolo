import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/widgets/depth_card.dart';
import '../../l10n/app_localizations.dart';
import '../assistant/assistant_settings.dart';
import 'speech_service.dart';

/// Builds the plain-text Voice check report. Technical facts only: no audio,
/// no recognised words, no contacts or records. Pure, so it's unit-tested.
String buildVoiceReport({
  required Map<String, Object?> env,
  required SpeechDiagnostics speech,
  required String speechLocale,
}) {
  final bn = speech.locales.where((l) => l.toLowerCase().startsWith('bn')).toList();
  final chosen = pickLocale(speechLocale, speech.locales);
  final b = StringBuffer()
    ..writeln('Bolo voice check')
    ..writeln('Phone: ${env['manufacturer'] ?? '?'} ${env['model'] ?? ''}'.trimRight())
    ..writeln('Android: ${env['android'] ?? '?'} (SDK ${env['sdk'] ?? '?'})')
    ..writeln('Mic permission: ${speech.hasPermission ? 'granted' : 'NOT granted'}')
    ..writeln('Recognizer ready: ${speech.initialised ? 'yes' : 'NO'}')
    ..writeln('Recognition available: ${env['recognitionAvailable'] ?? '?'}'
        ' / on-device: ${env['onDeviceAvailable'] ?? '?'}')
    ..writeln('Default recognizer: ${env['defaultRecognizer'] ?? '(not set / hidden)'}')
    ..writeln('Installed recognizers: ${(env['recognizers'] as List?)?.join(', ') ?? '?'}')
    ..writeln('Google app: ${env['googleApp'] ?? 'not installed'}')
    ..writeln('Speech Services by Google: ${env['speechServices'] ?? 'not installed'}')
    ..writeln('Play services: ${env['playServices'] ?? 'not installed'}')
    ..writeln('Mic inputs: ${(env['micInputs'] as List?)?.join(', ') ?? '?'}')
    ..writeln('Wake word using mic: ${env['wakeWordListening'] ?? '?'}')
    ..writeln('Speech language: $speechLocale -> $chosen')
    ..writeln('Languages reported: ${speech.locales.length}'
        '${bn.isEmpty ? ' (no Bangla)' : ' (Bangla: ${bn.join(', ')})'}')
    ..writeln('Last error: ${speech.lastError ?? 'none'}')
    ..writeln('Last peak mic level: ${speech.maxLevel.toStringAsFixed(2)}');
  return b.toString();
}

/// Settings card: runs the Voice check and lets the user copy the report.
class VoiceCheckCard extends ConsumerStatefulWidget {
  const VoiceCheckCard({super.key});

  @override
  ConsumerState<VoiceCheckCard> createState() => _VoiceCheckCardState();
}

class _VoiceCheckCardState extends ConsumerState<VoiceCheckCard> {
  String? _report;
  bool _running = false;

  Future<void> _run() async {
    setState(() => _running = true);
    final env = await ref.read(deviceBridgeProvider).speechEnvironment();
    final speech = await ref.read(speechServiceProvider).diagnostics();
    if (!mounted) return;
    setState(() {
      _running = false;
      _report = buildVoiceReport(env: env, speech: speech, speechLocale: ref.read(speechLocaleProvider));
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return DepthCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.mic_external_on_rounded),
          const SizedBox(width: 8),
          Text(l.voiceCheck, style: theme.textTheme.titleMedium),
        ]),
        const SizedBox(height: 8),
        Text(l.voiceCheckHint),
        const SizedBox(height: 8),
        Wrap(spacing: 8, children: [
          FilledButton.tonal(onPressed: _running ? null : _run, child: Text(l.voiceCheckRun)),
          if (_report != null)
            OutlinedButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                await Clipboard.setData(ClipboardData(text: _report!));
                messenger.showSnackBar(SnackBar(content: Text(l.voiceCheckCopied)));
              },
              child: Text(l.voiceCheckCopy),
            ),
        ]),
        if (_report != null) ...[
          const SizedBox(height: 8),
          SelectableText(_report!, style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace')),
        ],
      ]),
    );
  }
}
