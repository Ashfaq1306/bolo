import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../core/theme.dart';
import 'orb_face.dart';

/// Bolo's character: a GPU-shader 3D orb ([shaders/orb.frag]) with an
/// animated face on top. The face blinks, follows your finger, moves its mouth
/// with your voice (or while Bolo speaks), and changes expression by state.
///
/// With "reduce motion" on, or if the shader can't load (e.g. in tests), it
/// falls back to a static sphere with a calm face.
class VoiceOrb extends StatefulWidget {
  const VoiceOrb({
    super.key,
    required this.expression,
    required this.level,
    required this.onTap,
    required this.semanticLabel,
    this.pointer,
    this.size = 240,
  });

  final FaceExpression expression;

  /// 0..1 microphone loudness while listening.
  final double level;
  final VoidCallback onTap;
  final String semanticLabel;

  /// Global position of the user's finger anywhere on screen (eyes follow it).
  final ValueListenable<Offset?>? pointer;
  final double size;

  @override
  State<VoiceOrb> createState() => _VoiceOrbState();
}

class _VoiceOrbState extends State<VoiceOrb> with SingleTickerProviderStateMixin {
  static Future<ui.FragmentProgram>? _programFuture;
  ui.FragmentProgram? _program;
  late final Ticker _ticker;
  final _time = ValueNotifier<double>(0);
  final _rand = math.Random();

  double _smoothLevel = 0;
  FaceParams _face = const FaceParams();
  double _nextBlink = 2;
  double _blinkStart = -10;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick);
    _loadShader();
  }

  void _tick(Duration elapsed) {
    final t = elapsed.inMicroseconds / 1e6;
    final listening = widget.expression == FaceExpression.listening;
    final target = listening ? widget.level : 0.0;
    _smoothLevel += (target - _smoothLevel) * 0.18;

    // Mouth movement: real mic level when listening, a natural "talking"
    // rhythm while Bolo speaks (TTS doesn't expose audio loudness).
    final voice = switch (widget.expression) {
      FaceExpression.listening => _smoothLevel,
      FaceExpression.speaking => (0.25 + 0.5 * (0.5 + 0.5 * math.sin(t * 13)) * (0.6 + 0.4 * math.sin(t * 3.7))).clamp(0.0, 1.0),
      _ => 0.0,
    };

    var faceTarget = FaceParams.target(widget.expression, t, voice, _gaze());

    // Natural blinking every 2.5–5.5 s (not while smiling with ^ ^ eyes).
    if (t > _nextBlink) {
      _blinkStart = t;
      _nextBlink = t + 2.5 + _rand.nextDouble() * 3;
    }
    final sinceBlink = t - _blinkStart;
    if (sinceBlink < 0.16) {
      final closed = math.sin(sinceBlink / 0.16 * math.pi); // 0 → 1 → 0
      faceTarget = faceTarget.copyWith(eyeOpen: 1 - closed);
      _face = _face.lerpTo(faceTarget, 0.6); // blinks are fast
    } else {
      _face = _face.lerpTo(faceTarget, 0.14); // expressions ease smoothly
    }
    _time.value = t;
  }

  /// Converts the finger position into a -1..1 look direction.
  Offset? _gaze() {
    final global = widget.pointer?.value;
    if (global == null || !mounted) return null;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    final local = box.globalToLocal(global) - box.size.center(Offset.zero);
    final reach = box.size.shortestSide * 0.9;
    return Offset((local.dx / reach).clamp(-1.0, 1.0), (local.dy / reach).clamp(-1.0, 1.0));
  }

  Future<void> _loadShader() async {
    try {
      _programFuture ??= ui.FragmentProgram.fromAsset('shaders/orb.frag');
      final program = await _programFuture!;
      if (!mounted) return;
      setState(() => _program = program);
    } catch (e) {
      debugPrint('Orb shader unavailable, using fallback: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion && _ticker.isActive) _ticker.stop();
    if (!reduceMotion && !_ticker.isActive) _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _time.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final (a, b) = switch (widget.expression) {
      FaceExpression.idle => (BoloColors.violet, BoloColors.teal),
      FaceExpression.listening => (BoloColors.teal, BoloColors.pink),
      FaceExpression.thinking => (BoloColors.violet, BoloColors.amber),
      FaceExpression.speaking => (BoloColors.teal, BoloColors.violet),
      FaceExpression.happy => (BoloColors.teal, BoloColors.amber),
      FaceExpression.confused => (BoloColors.violet, BoloColors.pink),
    };
    final state = switch (widget.expression) {
      FaceExpression.listening || FaceExpression.speaking => 1.0,
      FaceExpression.thinking => 2.0,
      _ => 0.0,
    };
    // Orb radius in pixels (matches baseR in the shader: 0.58 of half-size).
    // The robot face (visor, ears, antenna) is drawn a bit larger than the
    // sphere so it reads clearly on small phones; ears poke out the sides.
    final radius = widget.size / 2 * 0.58 * 1.15;
    final dark = Theme.of(context).brightness == Brightness.dark;

    final Widget orb = (_program == null || reduceMotion)
        ? _FallbackOrb(colorA: a, colorB: b)
        : CustomPaint(
            painter: _OrbPainter(
              program: _program!,
              time: _time,
              level: () => _smoothLevel,
              state: state,
              colorA: a,
              colorB: b,
            ),
          );

    final face = CustomPaint(
      painter: FacePainter(
        params: () => reduceMotion ? FaceParams.target(widget.expression, 0, 0, null) : _face,
        radius: radius,
        dark: dark,
        time: () => _time.value,
        repaint: _time,
      ),
    );

    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: GestureDetector(
        onTap: widget.onTap,
        child: SizedBox.square(
          dimension: widget.size,
          child: RepaintBoundary(child: Stack(fit: StackFit.expand, children: [orb, face])),
        ),
      ),
    );
  }
}

class _OrbPainter extends CustomPainter {
  _OrbPainter({required this.program, required this.time, required this.level, required this.state, required this.colorA, required this.colorB})
      : super(repaint: time);

  final ui.FragmentProgram program;
  final ValueListenable<double> time;
  final double Function() level;
  final double state;
  final Color colorA, colorB;

  @override
  void paint(Canvas canvas, Size size) {
    final shader = program.fragmentShader();
    var i = 0;
    shader
      ..setFloat(i++, size.width)
      ..setFloat(i++, size.height)
      ..setFloat(i++, time.value)
      ..setFloat(i++, level())
      ..setFloat(i++, state)
      ..setFloat(i++, colorA.r)
      ..setFloat(i++, colorA.g)
      ..setFloat(i++, colorA.b)
      ..setFloat(i++, colorB.r)
      ..setFloat(i++, colorB.g)
      ..setFloat(i++, colorB.b);
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
    shader.dispose();
  }

  @override
  bool shouldRepaint(_OrbPainter old) =>
      old.state != state || old.colorA != colorA || old.colorB != colorB || old.program != program;
}

/// Static sphere for reduced motion / no shader support.
class _FallbackOrb extends StatelessWidget {
  const _FallbackOrb({required this.colorA, required this.colorB});
  final Color colorA, colorB;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.58,
        heightFactor: 0.58,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              center: const Alignment(-0.35, -0.4),
              colors: [Colors.white.withValues(alpha: 0.9), colorA, colorB.withValues(alpha: 0.9)],
              stops: const [0.0, 0.35, 1.0],
            ),
            boxShadow: [BoxShadow(color: colorB.withValues(alpha: 0.45), blurRadius: 48, spreadRadius: 6)],
          ),
        ),
      ),
    );
  }
}
