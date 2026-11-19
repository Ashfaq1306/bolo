import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'orb_face.dart';

/// A short-lived emotion shown on Bolo's face (e.g. happy after saving,
/// confused when it didn't understand). Null means "follow the normal state".
class FaceMoodNotifier extends Notifier<FaceExpression?> {
  Timer? _timer;

  @override
  FaceExpression? build() {
    ref.onDispose(() => _timer?.cancel());
    return null;
  }

  void flash(FaceExpression mood, {Duration duration = const Duration(milliseconds: 2200)}) {
    _timer?.cancel();
    state = mood;
    _timer = Timer(duration, () => state = null);
  }
}

final faceMoodProvider = NotifierProvider<FaceMoodNotifier, FaceExpression?>(FaceMoodNotifier.new);
