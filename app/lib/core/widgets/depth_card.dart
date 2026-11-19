import 'package:flutter/material.dart';

/// A card with real perspective: it tilts toward your finger in 3D while
/// pressed, with a glossy top edge and layered shadow for depth.
/// Cheap to render (no blur filters), so it's fine on low-end phones.
class DepthCard extends StatefulWidget {
  const DepthCard({super.key, required this.child, this.onTap, this.accent, this.padding = const EdgeInsets.all(16)});

  final Widget child;
  final VoidCallback? onTap;
  final Color? accent;
  final EdgeInsets padding;

  @override
  State<DepthCard> createState() => _DepthCardState();
}

class _DepthCardState extends State<DepthCard> {
  Offset _tilt = Offset.zero; // -1..1 in each axis

  void _update(Offset local, Size size) {
    setState(() {
      _tilt = Offset(
        (local.dx / size.width * 2 - 1).clamp(-1.0, 1.0),
        (local.dy / size.height * 2 - 1).clamp(-1.0, 1.0),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final accent = widget.accent ?? scheme.primary;
    final tilt = reduceMotion ? Offset.zero : _tilt;

    final transform = Matrix4.identity()
      ..setEntry(3, 2, 0.0012) // perspective
      ..rotateX(-tilt.dy * 0.08)
      ..rotateY(tilt.dx * 0.08);

    return LayoutBuilder(builder: (context, constraints) {
      return GestureDetector(
        onTap: widget.onTap,
        onPanDown: (d) => _update(d.localPosition, Size(constraints.maxWidth, 120)),
        onPanUpdate: (d) => _update(d.localPosition, Size(constraints.maxWidth, 120)),
        onPanEnd: (_) => setState(() => _tilt = Offset.zero),
        onPanCancel: () => setState(() => _tilt = Offset.zero),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          transform: transform,
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: dark
                  ? [Color.lerp(scheme.surface, accent, 0.16)!, scheme.surface]
                  : [Color.lerp(Colors.white, accent, 0.10)!, Colors.white],
            ),
            border: Border.all(color: accent.withValues(alpha: dark ? 0.28 : 0.20)),
            boxShadow: [
              BoxShadow(color: accent.withValues(alpha: dark ? 0.18 : 0.10), blurRadius: 24, offset: Offset(tilt.dx * -6, 10 + tilt.dy * -4)),
              BoxShadow(color: Colors.black.withValues(alpha: dark ? 0.35 : 0.06), blurRadius: 8, offset: const Offset(0, 3)),
            ],
          ),
          child: Stack(children: [
            // Glossy highlight along the top edge.
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: 1.2,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    Colors.transparent,
                    Colors.white.withValues(alpha: dark ? 0.35 : 0.8),
                    Colors.transparent,
                  ]),
                ),
              ),
            ),
            Padding(padding: widget.padding, child: widget.child),
          ]),
        ),
      );
    });
  }
}
