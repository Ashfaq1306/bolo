import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../inbox/inbox_store.dart';
import '../records/models.dart';
import '../voice/speech_service.dart';
import 'command_service.dart';
import 'parsed_command.dart';

enum CapturePhase { idle, listening, thinking }

enum CaptureMessage { none, micUnavailable, heardNothing, offlineSaved, quotaExceeded, serverError, tooLong, notSignedIn }

class CaptureState {
  const CaptureState({
    this.phase = CapturePhase.idle,
    this.transcript = '',
    this.level = 0,
    this.message = CaptureMessage.none,
    this.proposal,
    this.proposalSerial = 0,
  });

  final CapturePhase phase;
  final String transcript;
  final double level;
  final CaptureMessage message;

  /// A proposal waiting for the user's review on the confirmation card.
  final ParsedCommand? proposal;

  /// Increments with each new proposal so the UI opens the card exactly once.
  final int proposalSerial;

  CaptureState copyWith({CapturePhase? phase, String? transcript, double? level, CaptureMessage? message, ParsedCommand? proposal, int? proposalSerial}) =>
      CaptureState(
        phase: phase ?? this.phase,
        transcript: transcript ?? this.transcript,
        level: level ?? this.level,
        message: message ?? this.message,
        proposal: proposal ?? this.proposal,
        proposalSerial: proposalSerial ?? this.proposalSerial,
      );
}

/// Orchestrates: listen -> transcript -> parseCommand -> proposal.
/// It never saves anything; saving happens only from the confirmation card.
class CaptureController extends Notifier<CaptureState> {
  StreamSubscription<SpeechState>? _sub;
  bool _handledFinal = false;

  @override
  CaptureState build() {
    ref.onDispose(() => _sub?.cancel());
    return const CaptureState();
  }

  SpeechService get _speech => ref.read(speechServiceProvider);

  Future<void> toggleListening() async {
    if (state.phase == CapturePhase.listening) {
      await _speech.stop();
      return;
    }
    if (state.phase == CapturePhase.thinking) return;

    if (!await _speech.init()) {
      state = state.copyWith(message: CaptureMessage.micUnavailable);
      return;
    }
    _handledFinal = false;
    _sub ??= _speech.states.listen(_onSpeech);
    state = const CaptureState(phase: CapturePhase.listening);
    await _speech.start(localeId: ref.read(speechLocaleProvider));
  }

  void _onSpeech(SpeechState s) {
    if (state.phase != CapturePhase.listening) return;
    if (s.error != null && s.text.isEmpty) {
      state = state.copyWith(phase: CapturePhase.idle, level: 0, message: CaptureMessage.heardNothing);
      return;
    }
    state = state.copyWith(transcript: s.text, level: s.level);
    final ended = s.isFinal || !s.listening;
    if (ended && !_handledFinal) {
      _handledFinal = true;
      if (s.text.trim().isEmpty) {
        state = state.copyWith(phase: CapturePhase.idle, level: 0, message: CaptureMessage.heardNothing);
      } else {
        unawaited(submit(s.text, source: RecordSource.voice));
      }
    }
  }

  /// Sends text (spoken or typed) for understanding.
  Future<void> submit(String text, {required RecordSource source}) async {
    final clean = text.trim();
    if (clean.isEmpty) return;
    state = state.copyWith(phase: CapturePhase.thinking, transcript: clean, level: 0, message: CaptureMessage.none);
    try {
      final locale = ref.read(localeProvider).languageCode;
      final proposal = await ref.read(commandServiceProvider).parse(clean, source: source, locale: locale);
      state = CaptureState(transcript: clean, proposal: proposal, proposalSerial: state.proposalSerial + 1);
    } on ParseException catch (e) {
      var message = switch (e.failure) {
        ParseFailure.offline => CaptureMessage.offlineSaved,
        ParseFailure.quotaExceeded => CaptureMessage.quotaExceeded,
        ParseFailure.notSignedIn => CaptureMessage.notSignedIn,
        ParseFailure.tooLong => CaptureMessage.tooLong,
        ParseFailure.server => CaptureMessage.serverError,
      };
      if (e.failure == ParseFailure.offline) {
        await ref.read(inboxStoreProvider).add(
              InboxItem(text: clean, createdAt: ref.read(clockProvider)(), fromVoice: source == RecordSource.voice),
            );
        ref.invalidate(inboxItemsProvider);
      } else if (e.failure == ParseFailure.server || e.failure == ParseFailure.quotaExceeded) {
        // Still let the user add it by hand: open an empty card with the text.
        state = CaptureState(
          transcript: clean,
          message: message,
          proposal: ParsedCommand(intent: CommandIntent.unknown, confidence: 0, title: clean, transcript: clean, source: source),
          proposalSerial: state.proposalSerial + 1,
        );
        return;
      }
      state = CaptureState(transcript: clean, message: message, proposalSerial: state.proposalSerial);
    }
  }

  void clearMessage() => state = state.copyWith(message: CaptureMessage.none);
}

final captureControllerProvider = NotifierProvider<CaptureController, CaptureState>(CaptureController.new);

final inboxItemsProvider = Provider<List<InboxItem>>((ref) => ref.watch(inboxStoreProvider).load());
