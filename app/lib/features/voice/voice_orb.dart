import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../core/theme.dart';

enum OrbMode { idle, listening, thinking }

/// The 3D voice orb. Renders [shaders/orb.frag] on the GPU and reacts to the
/// microphone [level]. Falls back to a static gradient sphere when the user
/// has "reduce motion" on, or if the shader can't load (e.g. in tests).
class VoiceOrb extends StatefulWidget {
  const VoiceOrb({super.key, required this.mode, required this.level, required this.onTap, required this.semanticLabel, this.size = 240});

  final OrbMode mode;
  final double level;
  final VoidCallback onTap;
  final String semanticLabel;
  final double size;

  @override
  State<VoiceOrb> createState() => _VoiceOrbState();
}

class _VoiceOrbState extends State<VoiceOrb> with SingleTickerProviderStateMixin {
  static Future<ui.FragmentProgram>? _programFuture;
  ui.FragmentProgram? _program;
  late final Ticker _ticker;
  final _time = ValueNotifier<double>(0);
  double _smoothLevel = 0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      // Smooth the level so the orb doesn't jitter with every audio sample.
      final target = widget.mode == OrbMode.listening ? widget.level : 0.0;
      _smoothLevel += (target - _smoothLevel) * 0.18;
      _time.value = elapsed.inMicroseconds / 1e6;
    });
    _loadShader();
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
    final (a, b) = switch (widget.mode) {
      OrbMode.idle => (BoloColors.violet, BoloColors.teal),
      OrbMode.listening => (BoloColors.teal, BoloColors.pink),
      OrbMode.thinking => (BoloColors.violet, BoloColors.amber),
    };

    final Widget visual = (_program == null || reduceMotion)
        ? _FallbackOrb(colorA: a, colorB: b, active: widget.mode != OrbMode.idle)
        : CustomPaint(
            painter: _OrbPainter(
              program: _program!,
              time: _time,
              level: () => _smoothLevel,
              state: widget.mode.index.toDouble(),
              colorA: a,
              colorB: b,
            ),
          );

    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: GestureDetector(
        onTap: widget.onTap,
        child: SizedBox.square(dimension: widget.size, child: RepaintBoundary(child: visual)),
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
  const _FallbackOrb({required this.colorA, required this.colorB, required this.active});
  final Color colorA, colorB;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FractionallySizedBox(
        widthFactor: active ? 0.66 : 0.6,
        heightFactor: active ? 0.66 : 0.6,
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
