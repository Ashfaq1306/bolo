import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Bolo's moods.
enum FaceExpression { idle, listening, thinking, speaking, happy, confused }

/// All the numbers that describe Bolo's robot face at one moment. The face
/// animates by moving the *current* params toward the *target* params every
/// frame (see VoiceOrb).
class FaceParams {
  const FaceParams({
    this.eyeOpen = 1,
    this.eyeScale = 1,
    this.happyEyes = 0,
    this.smile = 0.35,
    this.mouthOpen = 0,
    this.mouthWidth = 1,
    this.mouthShiftX = 0,
    this.browRaise = 0,
    this.browTilt = 0,
    this.blush = 0,
    this.gazeX = 0,
    this.gazeY = 0,
    this.scan = 0,
    this.glow = 0.4,
  });

  final double eyeOpen; // 0 closed .. 1 open (blinks)
  final double eyeScale; // bigger LED eyes = attentive
  final double happyEyes; // 0 normal .. 1 "^ ^" LED arcs
  final double smile; // -1 frown .. 1 big smile (LED mouth curve)
  final double mouthOpen; // 0 flat .. 1 tall equalizer bars
  final double mouthWidth; // relative mouth width
  final double mouthShiftX; // -1..1
  final double browRaise; // 0..1 eyes lift a little (attentive)
  final double browTilt; // -1..1 confused: one eye squints
  final double blush; // 0..1 pixel cheeks
  final double gazeX, gazeY; // -1..1 where the eyes look
  final double scan; // 0..1 thinking: eyes become spinning loaders
  final double glow; // 0..1 antenna + ear light intensity

  static double _l(double a, double b, double t) => a + (b - a) * t;

  FaceParams lerpTo(FaceParams b, double t) => FaceParams(
        eyeOpen: _l(eyeOpen, b.eyeOpen, t),
        eyeScale: _l(eyeScale, b.eyeScale, t),
        happyEyes: _l(happyEyes, b.happyEyes, t),
        smile: _l(smile, b.smile, t),
        mouthOpen: _l(mouthOpen, b.mouthOpen, t),
        mouthWidth: _l(mouthWidth, b.mouthWidth, t),
        mouthShiftX: _l(mouthShiftX, b.mouthShiftX, t),
        browRaise: _l(browRaise, b.browRaise, t),
        browTilt: _l(browTilt, b.browTilt, t),
        blush: _l(blush, b.blush, t),
        gazeX: _l(gazeX, b.gazeX, t),
        gazeY: _l(gazeY, b.gazeY, t),
        scan: _l(scan, b.scan, t),
        glow: _l(glow, b.glow, t),
      );

  FaceParams copyWith({double? eyeOpen}) => FaceParams(
        eyeOpen: eyeOpen ?? this.eyeOpen,
        eyeScale: eyeScale,
        happyEyes: happyEyes,
        smile: smile,
        mouthOpen: mouthOpen,
        mouthWidth: mouthWidth,
        mouthShiftX: mouthShiftX,
        browRaise: browRaise,
        browTilt: browTilt,
        blush: blush,
        gazeX: gazeX,
        gazeY: gazeY,
        scan: scan,
        glow: glow,
      );

  /// Target face for a mood at time [t] (seconds), with the current [voice]
  /// level (0..1: microphone while listening, synthetic while speaking).
  static FaceParams target(FaceExpression e, double t, double voice, Offset? gaze) {
    // Idle eyes wander slowly when nobody is touching the screen.
    final wanderX = 0.35 * math.sin(t * 0.37) * math.sin(t * 0.11 + 1);
    final wanderY = 0.20 * math.sin(t * 0.29 + 2);
    final gx = gaze?.dx ?? wanderX;
    final gy = gaze?.dy ?? wanderY;
    switch (e) {
      case FaceExpression.idle:
        return FaceParams(smile: 0.35, gazeX: gx, gazeY: gy, glow: 0.35 + 0.15 * math.sin(t * 1.6));
      case FaceExpression.listening:
        return FaceParams(
          eyeScale: 1.15,
          smile: 0.15,
          mouthOpen: 0.12 + 0.8 * voice, // equalizer follows your voice
          mouthWidth: 0.9,
          browRaise: 0.6,
          gazeX: gaze?.dx ?? 0,
          gazeY: gaze?.dy ?? 0,
          glow: 0.75 + 0.25 * voice,
        );
      case FaceExpression.thinking:
        return FaceParams(
          eyeScale: 0.95,
          smile: 0,
          mouthOpen: 0.05,
          mouthWidth: 0.6,
          mouthShiftX: 0.3,
          browRaise: 0.4,
          gazeX: 0.4,
          gazeY: -0.5,
          scan: 1,
          glow: 0.5 + 0.5 * (0.5 + 0.5 * math.sin(t * 9)), // antenna blinks
        );
      case FaceExpression.speaking:
        return FaceParams(smile: 0.3, mouthOpen: voice, mouthWidth: 0.95, browRaise: 0.2, gazeX: gx * 0.3, gazeY: 0, glow: 0.55 + 0.4 * voice);
      case FaceExpression.happy:
        return const FaceParams(happyEyes: 1, smile: 1, mouthOpen: 0.25, mouthWidth: 1.15, browRaise: 0.35, blush: 1, glow: 1);
      case FaceExpression.confused:
        return FaceParams(
          eyeScale: 1.05,
          smile: -0.5,
          mouthOpen: 0.06,
          mouthWidth: 0.75,
          mouthShiftX: -0.2,
          browTilt: -1,
          browRaise: 0.3,
          gazeX: -0.3,
          gazeY: 0.2,
          glow: 0.3 + 0.3 * (0.5 + 0.5 * math.sin(t * 5)),
        );
    }
  }
}

/// Paints Bolo's cute robot face on top of the 3D orb: a glass visor with LED
/// eyes, headphone-style ears, an antenna, and an LED equalizer mouth.
/// [radius] is the orb's radius in pixels.
class FacePainter extends CustomPainter {
  FacePainter({required this.params, required this.radius, required this.dark, this.time, super.repaint});

  final FaceParams Function() params;
  final double radius;
  final bool dark;

  /// Seconds since start (drives LED animations). Null = static.
  final double Function()? time;

  static const _led = Color(0xFF7DF9FF); // cyan LED
  static const _ledHappy = Color(0xFFFFE27A); // warm LED when happy
  static const _metal = Color(0xFFCFD8E3);
  static const _metalDark = Color(0xFF6B7A90);

  @override
  void paint(Canvas canvas, Size size) {
    final p = params();
    final t = time?.call() ?? 0;
    final r = radius;
    final center = size.center(Offset.zero);
    final led = Color.lerp(_led, _ledHappy, p.happyEyes * 0.6)!;

    // Ears and antenna sit on the head itself (they don't slide with the gaze).
    _ears(canvas, center, r, p, led);
    _antenna(canvas, center, r, p, led, t);

    // Face features slide a little toward where Bolo looks: a head turning.
    final face = center + Offset(p.gazeX * 0.08 * r, p.gazeY * 0.06 * r);
    final squeeze = 1 - 0.10 * p.gazeX.abs();
    canvas.save();
    canvas.translate(face.dx, face.dy);
    canvas.scale(squeeze, 1);
    _visor(canvas, r, p, led, t);
    _cheeks(canvas, r, p);
    _mouth(canvas, r, p, led, t);
    canvas.restore();
  }

  Paint _glow(Color c, double sigma, {double alpha = 1}) => Paint()
    ..color = c.withValues(alpha: alpha.clamp(0.0, 1.0))
    ..maskFilter = MaskFilter.blur(BlurStyle.normal, sigma);

  // ---------- ears: round headphone pods with a glowing ring ----------
  void _ears(Canvas canvas, Offset c, double r, FaceParams p, Color led) {
    for (final side in [-1.0, 1.0]) {
      final ec = c + Offset(side * r * 0.98, r * 0.02);
      final er = r * 0.2;
      // Band connecting the ear to the head.
      final band = Rect.fromCenter(center: ec - Offset(side * er * 0.55, 0), width: er * 0.9, height: er * 1.2);
      canvas.drawRRect(RRect.fromRectAndRadius(band, Radius.circular(er * 0.3)), Paint()..color = _metalDark);
      // Pod.
      canvas.drawCircle(
        ec,
        er,
        Paint()
          ..shader = RadialGradient(
            center: Alignment(-0.4 * side, -0.5),
            colors: const [Colors.white, _metal, _metalDark],
            stops: const [0, 0.45, 1],
          ).createShader(Rect.fromCircle(center: ec, radius: er)),
      );
      // Glowing ring + dark core.
      canvas.drawCircle(ec, er * 0.62, _glow(led, er * 0.25, alpha: 0.35 + 0.65 * p.glow));
      canvas.drawCircle(
        ec,
        er * 0.55,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = er * 0.16
          ..color = led.withValues(alpha: (0.45 + 0.55 * p.glow).clamp(0.0, 1.0)),
      );
      canvas.drawCircle(ec, er * 0.22, Paint()..color = const Color(0xFF1B2333));
    }
  }

  // ---------- antenna with a pulsing bulb ----------
  void _antenna(Canvas canvas, Offset c, double r, FaceParams p, Color led, double t) {
    final base = c + Offset(0, -r * 0.93);
    final sway = math.sin(t * 2.2) * r * 0.03 * (1 + p.mouthOpen);
    final tip = base + Offset(sway, -r * 0.3);
    canvas.drawLine(
      base,
      tip,
      Paint()
        ..color = _metalDark
        ..strokeWidth = r * 0.05
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawOval(Rect.fromCenter(center: base, width: r * 0.26, height: r * 0.1), Paint()..color = _metal);
    final bulbR = r * 0.085;
    canvas.drawCircle(tip, bulbR * 2.2, _glow(led, bulbR, alpha: 0.25 + 0.75 * p.glow));
    canvas.drawCircle(tip, bulbR, Paint()..color = Color.lerp(_metal, led, (0.4 + 0.6 * p.glow).clamp(0.0, 1.0))!);
    canvas.drawCircle(tip - Offset(bulbR * 0.35, bulbR * 0.35), bulbR * 0.3, Paint()..color = Colors.white.withValues(alpha: 0.8));
  }

  // ---------- glass visor with LED eyes ----------
  void _visor(Canvas canvas, double r, FaceParams p, Color led, double t) {
    final visor = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(0, -r * 0.12), width: r * 1.42, height: r * 0.72),
      Radius.circular(r * 0.36),
    );
    canvas.drawRRect(
      visor,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFF1E2A44).withValues(alpha: 0.92), const Color(0xFF070B16).withValues(alpha: 0.95)],
        ).createShader(visor.outerRect),
    );
    canvas.drawRRect(
      visor,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.025
        ..color = Colors.white.withValues(alpha: 0.22),
    );
    // Glass reflection.
    final shine = Path()
      ..moveTo(visor.left + r * 0.18, visor.top + r * 0.07)
      ..quadraticBezierTo(visor.center.dx - r * 0.1, visor.top + r * 0.02, visor.center.dx + r * 0.05, visor.top + r * 0.06)
      ..quadraticBezierTo(visor.center.dx - r * 0.12, visor.top + r * 0.11, visor.left + r * 0.2, visor.top + r * 0.16)
      ..close();
    canvas.drawPath(shine, Paint()..color = Colors.white.withValues(alpha: 0.12));

    // Eye positions inside the visor follow the gaze.
    final dx = p.gazeX * r * 0.13;
    final dy = p.gazeY * r * 0.08;
    for (final left in [true, false]) {
      final side = left ? -1.0 : 1.0;
      final ec = Offset(side * r * 0.32 + dx, -r * 0.12 + dy - p.browRaise * r * 0.02);
      // Confused: one eye squints smaller.
      final tilt = left ? -p.browTilt : p.browTilt;
      final scale = p.eyeScale * (1 - 0.28 * tilt.clamp(0.0, 1.0));
      _eye(canvas, ec, r, scale, p, led, t, left);
    }
  }

  void _eye(Canvas canvas, Offset c, double r, double scale, FaceParams p, Color led, double t, bool left) {
    final w = r * 0.26 * scale;
    final h = r * 0.34 * scale;
    final normal = ((1 - p.happyEyes) * (1 - p.scan)).clamp(0.0, 1.0);

    // Normal LED capsule eye (blinks by collapsing to a line).
    if (normal > 0.01) {
      final eh = math.max(h * p.eyeOpen, r * 0.035);
      final rect = Rect.fromCenter(center: c, width: w, height: eh);
      final rr = RRect.fromRectAndRadius(rect, Radius.circular(math.min(w, eh) / 2));
      canvas.drawRRect(rr.inflate(r * 0.03), _glow(led, r * 0.06, alpha: 0.55 * normal));
      canvas.drawRRect(rr, Paint()..color = led.withValues(alpha: normal));
      // LED scanlines + a square highlight: robotic, not human.
      if (p.eyeOpen > 0.5) {
        final lines = Paint()
          ..color = Colors.black.withValues(alpha: 0.12 * normal)
          ..strokeWidth = r * 0.012;
        for (var y = rect.top + r * 0.04; y < rect.bottom; y += r * 0.05) {
          canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), lines);
        }
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(rect.left + w * 0.18, rect.top + eh * 0.12, w * 0.28, eh * 0.22),
            Radius.circular(w * 0.1),
          ),
          Paint()..color = Colors.white.withValues(alpha: 0.75 * normal),
        );
      }
    }

    // Happy "^ ^" LED arcs.
    if (p.happyEyes > 0.01) {
      final a = (p.happyEyes * (1 - p.scan)).clamp(0.0, 1.0);
      final path = Path()
        ..moveTo(c.dx - w * 0.6, c.dy + h * 0.12)
        ..quadraticBezierTo(c.dx, c.dy - h * 0.55, c.dx + w * 0.6, c.dy + h * 0.12);
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = r * 0.13
          ..color = led.withValues(alpha: 0.4 * a)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.05),
      );
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = r * 0.075
          ..color = led.withValues(alpha: a),
      );
    }

    // Thinking: each eye becomes a spinning loader ring.
    if (p.scan > 0.01) {
      final s = p.scan.clamp(0.0, 1.0);
      final ringR = w * 0.55;
      final start = t * 6 + (left ? 0 : math.pi);
      final rect = Rect.fromCircle(center: c, radius: ringR);
      canvas.drawArc(
        rect,
        start,
        math.pi * 1.3,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * 0.11
          ..strokeCap = StrokeCap.round
          ..color = led.withValues(alpha: 0.35 * s)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.04),
      );
      canvas.drawArc(
        rect,
        start,
        math.pi * 1.3,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * 0.06
          ..strokeCap = StrokeCap.round
          ..color = led.withValues(alpha: s),
      );
    }
  }

  // ---------- pixel blush ----------
  void _cheeks(Canvas canvas, double r, FaceParams p) {
    if (p.blush <= 0.01) return;
    final paint = Paint()..color = const Color(0xFFFF7FB0).withValues(alpha: (0.85 * p.blush).clamp(0.0, 1.0));
    final s = r * 0.055;
    for (final side in [-1.0, 1.0]) {
      final base = Offset(side * r * 0.56, r * 0.3);
      for (var i = 0; i < 3; i++) {
        final o = base + Offset((i - 1) * s * 1.4, i == 1 ? -s * 0.5 : 0);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: o, width: s, height: s), Radius.circular(s * 0.25)), paint);
      }
    }
  }

  // ---------- LED equalizer mouth ----------
  void _mouth(Canvas canvas, double r, FaceParams p, Color led, double t) {
    const bars = 7;
    final width = r * 0.62 * p.mouthWidth;
    final cx = p.mouthShiftX * r * 0.12;
    final cy = r * 0.45;
    final step = width / (bars - 1);
    final barW = step * 0.62;
    final glow = _glow(led, r * 0.04, alpha: 0.5);
    final solid = Paint()..color = led;
    for (var i = 0; i < bars; i++) {
      final u = (i / (bars - 1)) * 2 - 1; // -1..1 across the mouth
      // Smile curve: the ends lift when happy, drop when sad.
      final curveY = -p.smile * r * 0.12 * (u * u);
      // Equalizer: each bar bounces at its own rhythm with the voice.
      final wave = 0.55 + 0.45 * math.sin(t * 11 + i * 1.7) * math.sin(t * 4.3 + i);
      final centerBoost = 1 - 0.45 * u.abs();
      final h = r * 0.05 + r * 0.32 * p.mouthOpen.clamp(0.0, 1.0) * wave * centerBoost;
      final rect = Rect.fromCenter(center: Offset(cx + u * width / 2, cy + curveY), width: barW, height: h);
      final rr = RRect.fromRectAndRadius(rect, Radius.circular(barW / 2));
      canvas.drawRRect(rr.inflate(r * 0.012), glow);
      canvas.drawRRect(rr, solid);
    }
  }

  @override
  bool shouldRepaint(FacePainter old) => old.radius != radius || old.dark != dark || old.params != params;
}
