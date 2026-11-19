import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Bolo's facial expressions.
enum FaceExpression { idle, listening, thinking, speaking, happy, confused }

/// All the numbers that describe a face at one moment. The face animates by
/// smoothly moving the *current* params toward the *target* params every frame.
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
  });

  final double eyeOpen; // 0 closed .. 1 open (blinks)
  final double eyeScale; // bigger eyes = attentive
  final double happyEyes; // 0 normal .. 1 "^ ^" smiling eyes
  final double smile; // -1 frown .. 1 big smile
  final double mouthOpen; // 0 closed .. 1 wide open
  final double mouthWidth; // relative
  final double mouthShiftX; // -1..1 (thinking: mouth to the side)
  final double browRaise; // 0..1
  final double browTilt; // -1..1 (confused: one brow up, one down)
  final double blush; // 0..1
  final double gazeX, gazeY; // -1..1 where the eyes look

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
      );

  /// Target face for an expression at time [t] (seconds), with the current
  /// [voice] level (0..1: microphone while listening, synthetic while speaking).
  static FaceParams target(FaceExpression e, double t, double voice, Offset? gaze) {
    // Idle eyes wander slowly when nobody is touching the screen.
    final wanderX = 0.35 * math.sin(t * 0.37) * math.sin(t * 0.11 + 1);
    final wanderY = 0.20 * math.sin(t * 0.29 + 2);
    final gx = gaze?.dx ?? wanderX;
    final gy = gaze?.dy ?? wanderY;
    switch (e) {
      case FaceExpression.idle:
        return FaceParams(smile: 0.35, gazeX: gx, gazeY: gy);
      case FaceExpression.listening:
        return FaceParams(
          eyeScale: 1.12,
          smile: 0.1,
          mouthOpen: 0.12 + 0.55 * voice, // "o" that follows your voice
          mouthWidth: 0.75,
          browRaise: 0.55,
          gazeX: gaze?.dx ?? 0,
          gazeY: gaze?.dy ?? 0,
        );
      case FaceExpression.thinking:
        return FaceParams(
          eyeScale: 0.95,
          smile: -0.05,
          mouthOpen: 0.05,
          mouthWidth: 0.55,
          mouthShiftX: 0.45,
          browRaise: 0.4,
          browTilt: 0.6,
          gazeX: 0.55 + 0.1 * math.sin(t * 3), // looking up and to the side
          gazeY: -0.75,
        );
      case FaceExpression.speaking:
        return FaceParams(smile: 0.3, mouthOpen: voice, mouthWidth: 0.85, browRaise: 0.2, gazeX: gx * 0.3, gazeY: 0);
      case FaceExpression.happy:
        return FaceParams(happyEyes: 1, smile: 1, mouthOpen: 0.35, mouthWidth: 1.15, browRaise: 0.35, blush: 1, gazeX: 0, gazeY: 0);
      case FaceExpression.confused:
        return FaceParams(
          eyeScale: 1.05,
          smile: -0.45,
          mouthOpen: 0.06,
          mouthWidth: 0.7,
          mouthShiftX: -0.25,
          browTilt: -1,
          browRaise: 0.3,
          gazeX: -0.3,
          gazeY: 0.2,
        );
    }
  }
}

/// Paints eyes, nose, mouth, brows and blush on top of the 3D orb.
/// [radius] is the orb's radius in pixels; the face sits on the sphere and
/// shifts with the gaze so it looks like it's turning in 3D.
class FacePainter extends CustomPainter {
  FacePainter({required this.params, required this.radius, required this.dark, super.repaint});

  final FaceParams Function() params;
  final double radius;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final p = params();
    final r = radius;
    // The whole face slides a little toward where it looks: a sphere turning.
    final center = size.center(Offset(p.gazeX * 0.10 * r, p.gazeY * 0.08 * r + 0.04 * r));
    // Foreshortening: features squeeze horizontally when turned sideways.
    final squeeze = 1 - 0.12 * p.gazeX.abs();

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(squeeze, 1);

    _blush(canvas, p, r);
    _eye(canvas, p, r, left: true);
    _eye(canvas, p, r, left: false);
    _brows(canvas, p, r);
    _nose(canvas, p, r);
    _mouth(canvas, p, r);

    canvas.restore();
  }

  void _blush(Canvas canvas, FaceParams p, double r) {
    if (p.blush < 0.02) return;
    final paint = Paint()
      ..shader = RadialGradient(colors: [
        const Color(0xFFFF7EB6).withValues(alpha: 0.55 * p.blush),
        const Color(0x00FF7EB6),
      ]).createShader(Rect.fromCircle(center: Offset.zero, radius: 0.16 * r));
    for (final x in [-0.42, 0.42]) {
      canvas.save();
      canvas.translate(x * r, 0.14 * r);
      canvas.drawCircle(Offset.zero, 0.16 * r, paint);
      canvas.restore();
    }
  }

  void _eye(Canvas canvas, FaceParams p, double r, {required bool left}) {
    final side = left ? -1.0 : 1.0;
    final c = Offset(side * 0.27 * r, -0.12 * r);
    final w = 0.19 * r * p.eyeScale;
    final h = 0.23 * r * p.eyeScale;

    // "^ ^" happy eyes replace the open eye as happyEyes -> 1.
    if (p.happyEyes > 0.5) {
      final arc = Path()
        ..moveTo(c.dx - w * 0.8, c.dy + h * 0.15)
        ..quadraticBezierTo(c.dx, c.dy - h * 0.75, c.dx + w * 0.8, c.dy + h * 0.15);
      canvas.drawPath(
        arc,
        Paint()
          ..color = const Color(0xFF1B1446)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.05 * r
          ..strokeCap = StrokeCap.round,
      );
      return;
    }

    final open = p.eyeOpen.clamp(0.06, 1.0);
    final eyeRect = Rect.fromCenter(center: c, width: w * 2, height: h * 2 * open);

    // Soft shadow under the eye gives depth on the sphere.
    canvas.drawOval(eyeRect.shift(Offset(0, 0.02 * r)), Paint()..color = const Color(0x55000022));
    // White of the eye with a subtle gradient (looks spherical).
    canvas.drawOval(
      eyeRect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.4),
          colors: const [Colors.white, Color(0xFFDCE6FF)],
        ).createShader(eyeRect),
    );

    // Iris and pupil follow the gaze, clipped to the eye shape.
    canvas.save();
    canvas.clipPath(Path()..addOval(eyeRect));
    final irisR = 0.115 * r * p.eyeScale;
    final iris = c + Offset(p.gazeX * w * 0.45, p.gazeY * h * 0.40 * open);
    canvas.drawCircle(
      iris,
      irisR,
      Paint()
        ..shader = RadialGradient(colors: const [Color(0xFF6D5BFF), Color(0xFF241A6B)])
            .createShader(Rect.fromCircle(center: iris, radius: irisR)),
    );
    canvas.drawCircle(iris, irisR * 0.52, Paint()..color = const Color(0xFF0B0820));
    // Two catch-lights make the eyes look alive.
    canvas.drawCircle(iris + Offset(-irisR * 0.35, -irisR * 0.4), irisR * 0.28, Paint()..color = Colors.white);
    canvas.drawCircle(iris + Offset(irisR * 0.35, irisR * 0.3), irisR * 0.12, Paint()..color = Colors.white70);
    canvas.restore();

    // Upper lid line.
    canvas.drawArc(
      eyeRect,
      math.pi * 1.1,
      math.pi * 0.8,
      false,
      Paint()
        ..color = const Color(0xFF1B1446).withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.022 * r
        ..strokeCap = StrokeCap.round,
    );
  }

  void _brows(Canvas canvas, FaceParams p, double r) {
    final paint = Paint()
      ..color = const Color(0xFF1B1446).withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.035 * r
      ..strokeCap = StrokeCap.round;
    for (final side in [-1.0, 1.0]) {
      final lift = (0.30 + 0.10 * p.browRaise) * r * p.eyeScale;
      // browTilt: one brow up and one down (confused / thinking).
      final tilt = p.browTilt * side * 0.06 * r;
      final y = -0.12 * r - lift - tilt;
      final x = side * 0.27 * r;
      final path = Path()
        ..moveTo(x - 0.12 * r, y + 0.03 * r + side * p.browTilt * 0.02 * r)
        ..quadraticBezierTo(x, y - 0.03 * r, x + 0.12 * r, y + 0.03 * r - side * p.browTilt * 0.02 * r);
      canvas.drawPath(path, paint);
    }
  }

  void _nose(Canvas canvas, FaceParams p, double r) {
    // A small rounded nose: a soft highlight with a shadow under it.
    final c = Offset(0, 0.07 * r);
    canvas.drawOval(
      Rect.fromCenter(center: c + Offset(0, 0.025 * r), width: 0.11 * r, height: 0.05 * r),
      Paint()..color = const Color(0x44000022),
    );
    canvas.drawOval(
      Rect.fromCenter(center: c, width: 0.10 * r, height: 0.07 * r),
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.5),
          colors: [Colors.white.withValues(alpha: 0.85), Colors.white.withValues(alpha: 0.15)],
        ).createShader(Rect.fromCenter(center: c, width: 0.10 * r, height: 0.07 * r)),
    );
  }

  void _mouth(Canvas canvas, FaceParams p, double r) {
    final cx = p.mouthShiftX * 0.10 * r;
    final cy = 0.27 * r;
    final half = 0.17 * r * p.mouthWidth;
    final curve = p.smile * 0.09 * r; // + = corners up
    final open = p.mouthOpen.clamp(0.0, 1.0) * 0.20 * r;

    final left = Offset(cx - half, cy - curve);
    final right = Offset(cx + half, cy - curve);
    final upperMid = Offset(cx, cy + curve * 0.6);
    final lowerMid = Offset(cx, cy + curve * 0.6 + open + curve * 0.4);

    final lipPaint = Paint()
      ..color = const Color(0xFF1B1446)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.035 * r
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (open < 0.012 * r) {
      // Closed mouth: a single curved line.
      final line = Path()
        ..moveTo(left.dx, left.dy)
        ..quadraticBezierTo(upperMid.dx, upperMid.dy + curve * 0.6, right.dx, right.dy);
      canvas.drawPath(line, lipPaint);
      return;
    }

    final mouth = Path()
      ..moveTo(left.dx, left.dy)
      ..quadraticBezierTo(upperMid.dx, upperMid.dy, right.dx, right.dy)
      ..quadraticBezierTo(lowerMid.dx, lowerMid.dy + open * 0.6, left.dx, left.dy)
      ..close();
    // Inside of the mouth, with a tongue when it's open enough.
    canvas.drawPath(mouth, Paint()..color = const Color(0xFF2B0D3D));
    canvas.save();
    canvas.clipPath(mouth);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, lowerMid.dy + open * 0.2), width: half * 1.1, height: open * 1.1),
      Paint()..color = const Color(0xFFFF6F91),
    );
    canvas.restore();
    canvas.drawPath(mouth, lipPaint..strokeWidth = 0.028 * r);
  }

  @override
  bool shouldRepaint(FacePainter old) => old.radius != radius || old.dark != dark;
}
