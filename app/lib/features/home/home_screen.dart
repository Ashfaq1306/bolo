import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dhaka_time.dart';
import '../../core/money.dart';
import '../../core/providers.dart';
import '../../core/theme.dart';
import '../../core/widgets/depth_card.dart';
import '../../l10n/app_localizations.dart';
import '../assistant/assistant_actions.dart';
import '../assistant/assistant_settings.dart';
import '../command/capture_controller.dart';
import '../command/confirmation_sheet.dart';
import '../command/parsed_command.dart';
import '../command/spoken_summary.dart';
import '../receipt/scan_flow.dart';
import '../voice/face_mood.dart';
import '../voice/orb_face.dart';
import '../records/models.dart';
import '../voice/voice_orb.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, this.privacy = false});

  /// Shown over the lock screen after "Bolo!": only the robot and what it
  /// hears; no totals, reminders or other personal data.
  final bool privacy;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  /// Where the user's finger is (Bolo's eyes follow it).
  final _pointer = ValueNotifier<Offset?>(null);

  @override
  void dispose() {
    _pointer.dispose();
    super.dispose();
  }

  /// Bolo says the proposal out loud (if voice replies are on).
  void _speak(String text) {
    if (!ref.read(voiceRepliesProvider)) return;
    ref.read(voiceReplyProvider).speak(text, languageCode: ref.read(localeProvider).languageCode);
  }

  String _message(AppLocalizations l, CaptureMessage m) => switch (m) {
        CaptureMessage.none => '',
        CaptureMessage.micUnavailable => l.micUnavailable,
        CaptureMessage.heardNothing => l.heardNothing,
        CaptureMessage.offlineSaved => l.offlineSaved,
        CaptureMessage.quotaExceeded => l.quotaExceeded,
        CaptureMessage.serverError => l.serverError,
        CaptureMessage.tooLong => l.tooLong,
        CaptureMessage.notSignedIn => l.notSignedIn,
      };

  Future<void> _typeCommand(BuildContext context) async {
    final text = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _TypeCommandSheet(),
    );
    if (text != null && text.trim().isNotEmpty) {
      await ref.read(captureControllerProvider.notifier).submit(text, source: RecordSource.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final capture = ref.watch(captureControllerProvider);
    final now = ref.watch(clockProvider)();
    final mood = ref.watch(faceMoodProvider);
    final name = assistantDisplayName(ref.watch(assistantNameProvider), lang);

    // Open the confirmation card once per new proposal, and say it out loud.
    ref.listen(captureControllerProvider, (prev, next) {
      if (next.proposal != null && next.proposalSerial != prev?.proposalSerial) {
        final proposal = next.proposal!;
        if (proposal.intent == CommandIntent.querySummary) {
          ref.read(faceMoodProvider.notifier).flash(FaceExpression.happy);
          return; // the summary is right here on this screen
        }
        ref.read(wakeSessionProvider.notifier).touch();
        if (proposal.intent.isAction) {
          // Call / play / open: do it (the call sheet confirms first).
          runAssistantAction(context, ref, proposal);
          return;
        }
        if (proposal.intent == CommandIntent.unknown) {
          ref.read(faceMoodProvider.notifier).flash(FaceExpression.confused);
        }
        _speak(spokenSummary(proposal, l, lang));
        showConfirmationSheet(context, ref, proposal).then((_) => ref.read(wakeSessionProvider.notifier).touch(idle: const Duration(seconds: 4)));
      } else if (next.message != CaptureMessage.none && next.message != prev?.message) {
        ref.read(faceMoodProvider.notifier).flash(FaceExpression.confused);
      }
    });

    final greeting = switch (DhakaTime.greetingKey(now)) {
      'morning' => l.greetingMorning,
      'afternoon' => l.greetingAfternoon,
      'evening' => l.greetingEvening,
      _ => l.greetingNight,
    };
    final phaseFace = switch (capture.phase) {
      CapturePhase.idle => FaceExpression.idle,
      CapturePhase.listening => FaceExpression.listening,
      CapturePhase.thinking => FaceExpression.thinking,
    };
    final status = switch (capture.phase) {
      CapturePhase.listening => capture.transcript.isEmpty ? l.listening : capture.transcript,
      CapturePhase.thinking => l.thinking,
      CapturePhase.idle => capture.message != CaptureMessage.none ? _message(l, capture.message) : l.tapToSpeak(name),
    };
    final speechLocale = ref.watch(speechLocaleProvider);

    // Track the finger anywhere on the screen so Bolo can look at it.
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (e) => _pointer.value = e.position,
      onPointerMove: (e) => _pointer.value = e.position,
      onPointerUp: (_) => _pointer.value = null,
      onPointerCancel: (_) => _pointer.value = null,
      child: Stack(children: [
      const Positioned.fill(child: _StarField()),
      SafeArea(
        child: CustomScrollView(slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(greeting, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                    Text(DhakaTime.formatDate(now, lang), style: Theme.of(context).textTheme.bodyMedium),
                  ]),
                ),
                // Which language the recognizer listens for.
                SegmentedButton<String>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: 'bn-BD', label: Text('বাং')),
                    ButtonSegment(value: 'en-US', label: Text('EN')),
                  ],
                  selected: {speechLocale},
                  onSelectionChanged: (s) => ref.read(speechLocaleProvider.notifier).set(s.first),
                ),
              ]),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(children: [
              const SizedBox(height: 8),
              ValueListenableBuilder<bool>(
                valueListenable: ref.watch(voiceReplyProvider).speaking,
                builder: (context, speaking, _) => VoiceOrb(
                // Priority: a short emotion (happy/confused) > speaking > state.
                expression: mood ?? (speaking ? FaceExpression.speaking : phaseFace),
                pointer: _pointer,
                level: capture.level,
                semanticLabel: l.orbLabel,
                size: math.min(MediaQuery.sizeOf(context).width * 0.72, 300),
                onTap: () {
                  ref.read(voiceReplyProvider).stop(); // tapping interrupts Bolo's speech
                  ref.read(captureControllerProvider.notifier).toggleListening();
                },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Semantics(
                  liveRegion: true,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      status,
                      key: ValueKey(status),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (!widget.privacy) Wrap(alignment: WrapAlignment.center, spacing: 8, children: [
                TextButton.icon(
                  onPressed: capture.phase == CapturePhase.idle ? () => _typeCommand(context) : null,
                  icon: const Icon(Icons.keyboard_rounded),
                  label: Text(l.typeInstead),
                ),
                TextButton.icon(
                  onPressed: capture.phase == CapturePhase.idle ? () => scanReceiptFlow(context, ref) : null,
                  icon: const Icon(Icons.document_scanner_rounded),
                  label: Text(l.scanReceipt),
                ),
              ]),
              const SizedBox(height: 8),
            ]),
          ),
          if (!widget.privacy)
            const SliverPadding(padding: EdgeInsets.fromLTRB(16, 0, 16, 24), sliver: SliverToBoxAdapter(child: TodaySummaryView()))
          else
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(l.lockedHint, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
              ),
            ),
        ]),
      ),
    ]),
    );
  }
}

/// Bottom sheet for typing a command. It owns its TextEditingController so the
/// controller is disposed only after the sheet's closing animation finishes
/// (disposing it earlier crashes: the TextField is still on screen).
class _TypeCommandSheet extends StatefulWidget {
  const _TypeCommandSheet();
  @override
  State<_TypeCommandSheet> createState() => _TypeCommandSheetState();
}

class _TypeCommandSheetState extends State<_TypeCommandSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: Row(children: [
        Expanded(
          child: TextField(
            controller: _controller,
            autofocus: true,
            maxLength: 500,
            minLines: 1,
            maxLines: 4,
            // The keyboard's action key sends (instead of adding a new line).
            textInputAction: TextInputAction.send,
            decoration: InputDecoration(hintText: l.inputHint),
            onSubmitted: (v) => Navigator.pop(context, v),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filled(
          tooltip: l.send,
          onPressed: () => Navigator.pop(context, _controller.text),
          icon: const Icon(Icons.send_rounded),
        ),
      ]),
    );
  }
}

/// The Today summary cards (computed on-device, docs/03 § F9).
class TodaySummaryView extends ConsumerWidget {
  const TodaySummaryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final s = ref.watch(dailySummaryProvider);
    final theme = Theme.of(context);

    Widget stat(String label, int poisha, Color color, IconData icon) => Expanded(
          child: DepthCard(
            accent: color,
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 6),
                Flexible(child: Text(label, style: theme.textTheme.labelLarge, overflow: TextOverflow.ellipsis)),
              ]),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(Money.format(poisha, languageCode: lang),
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
              ),
            ]),
          ),
        );

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        stat(l.spentToday, s.spentTodayPoisha, BoloColors.violet, Icons.today_rounded),
        const SizedBox(width: 12),
        stat(l.spentMonth, s.spentMonthPoisha, BoloColors.teal, Icons.calendar_month_rounded),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        stat(l.toReceive, s.toReceivePoisha, BoloColors.receive, Icons.call_received_rounded),
        const SizedBox(width: 12),
        stat(l.toPay, s.toPayPoisha, BoloColors.pay, Icons.call_made_rounded),
      ]),
      const SizedBox(height: 12),
      if (s.remindersToday.isEmpty && s.tasksDueOrOverdue.isEmpty)
        DepthCard(
          child: Text(
            s.isEmpty ? l.nothingToday(assistantDisplayName(ref.watch(assistantNameProvider), lang)) : l.nothingPlannedToday,
            textAlign: TextAlign.center,
          ),
        )
      else ...[
        if (s.remindersToday.isNotEmpty)
          DepthCard(
            accent: BoloColors.amber,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l.remindersToday, style: theme.textTheme.titleMedium),
              for (final r in s.remindersToday)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.alarm_rounded),
                  title: Text(r.title),
                  trailing: Text(DhakaTime.formatTime(r.remindAt, lang)),
                ),
            ]),
          ),
        const SizedBox(height: 12),
        if (s.tasksDueOrOverdue.isNotEmpty)
          DepthCard(
            accent: BoloColors.pink,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l.dueTasks, style: theme.textTheme.titleMedium),
              for (final t in s.tasksDueOrOverdue)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: false,
                  title: Text(t.title),
                  subtitle: Text(DhakaTime.formatDate(t.dueAt!, lang)),
                  onChanged: (_) => ref.read(recordsRepositoryProvider)?.setTaskDone(t.id, true),
                ),
            ]),
          ),
      ],
    ]);
  }
}

/// Slowly drifting stars give the home screen depth (parallax layers).
class _StarField extends StatefulWidget {
  const _StarField();
  @override
  State<_StarField> createState() => _StarFieldState();
}

class _StarFieldState extends State<_StarField> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 60));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).brightness != Brightness.dark) return const SizedBox.shrink();
    return RepaintBoundary(child: CustomPaint(painter: _StarPainter(_c)));
  }
}

class _StarPainter extends CustomPainter {
  _StarPainter(this.t) : super(repaint: t);
  final Animation<double> t;
  static final _stars = List.generate(70, (i) {
    final r = math.Random(i * 7919);
    return (r.nextDouble(), r.nextDouble(), r.nextDouble()); // x, y, depth
  });

  @override
  void paint(Canvas canvas, Size size) {
    final glow = Paint()
      ..shader = RadialGradient(colors: [BoloColors.violet.withValues(alpha: 0.22), Colors.transparent])
          .createShader(Rect.fromCircle(center: Offset(size.width / 2, size.height * 0.22), radius: size.width * 0.9));
    canvas.drawRect(Offset.zero & size, glow);
    final p = Paint();
    for (final (x, y, depth) in _stars) {
      // Nearer stars (higher depth) move faster: a parallax effect.
      final dy = (y + t.value * (0.02 + depth * 0.08)) % 1.0;
      p.color = Colors.white.withValues(alpha: 0.15 + depth * 0.45);
      canvas.drawCircle(Offset(x * size.width, dy * size.height), 0.6 + depth * 1.4, p);
    }
  }

  @override
  bool shouldRepaint(_StarPainter old) => false;
}
