import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// App-wide ambient background: a deep gradient with soft coloured light
/// orbs. A glass surface only looks like glass when there is something
/// colourful behind it to blur, so this sits under every screen (see
/// `MaterialApp.builder` in main.dart). It is static (no animation) and
/// isolated in a [RepaintBoundary] so scrolling never repaints it.
class GlassBackground extends StatelessWidget {
  const GlassBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const RepaintBoundary(child: _AmbientBackdrop()),
        child,
      ],
    );
  }
}

class _AmbientBackdrop extends StatelessWidget {
  const _AmbientBackdrop();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0F0B24), Color(0xFF07070D)],
            ),
          ),
        ),
        _GlowOrb(
          alignment: Alignment(-1.1, -0.85),
          size: 480,
          color: Color(0xFF7C3AED),
          opacity: 0.60,
        ),
        _GlowOrb(
          alignment: Alignment(1.25, -0.15),
          size: 440,
          color: Color(0xFF2563EB),
          opacity: 0.50,
        ),
        _GlowOrb(
          alignment: Alignment(-0.7, 1.15),
          size: 500,
          color: Color(0xFFDB2777),
          opacity: 0.30,
        ),
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.alignment,
    required this.size,
    required this.color,
    required this.opacity,
  });

  final Alignment alignment;
  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: IgnorePointer(
        child: SizedBox(
          width: size,
          height: size,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  color.withValues(alpha: opacity),
                  color.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Frosted-glass surface.
///
/// Layers, bottom to top: backdrop blur of whatever is behind it, a diagonal
/// tint gradient (lighter at the top-left like light hitting glass), a soft
/// sheen over the top half, and a 1px gradient rim (bright top-left, faint
/// middle, medium bottom-right). Content sits on a transparent [Material] so
/// ink splashes and list tiles render above the glass, not under it.
///
/// Set [blurEnabled] to false for a cheaper, blur-free fallback.
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(12),
    this.radius = 18,
    this.blurEnabled = true,
    this.blurSigma = 24,
    this.tint = const Color(0x591B1B2E),
    this.borderColor = const Color(0x40FFFFFF),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool blurEnabled;
  final double blurSigma;
  final Color tint;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final shape = BorderRadius.circular(radius);

    Widget glass = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.alphaBlend(const Color(0x2EFFFFFF), tint),
            tint,
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          const Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.center,
                    colors: [Color(0x1FFFFFFF), Color(0x00FFFFFF)],
                  ),
                ),
              ),
            ),
          ),
          Material(
            type: MaterialType.transparency,
            child: Padding(padding: padding, child: child),
          ),
        ],
      ),
    );

    if (blurEnabled) {
      glass = BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: glass,
      );
    }

    return ClipRRect(
      borderRadius: shape,
      child: CustomPaint(
        foregroundPainter: _GlassRimPainter(radius: radius, color: borderColor),
        child: glass,
      ),
    );
  }
}

class _GlassRimPainter extends CustomPainter {
  const _GlassRimPainter({required this.radius, required this.color});

  final double radius;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final rect = (Offset.zero & size).deflate(0.5);
    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(math.max(radius - 0.5, 0)),
    );
    final bright = color.withValues(alpha: math.min(1.0, color.a * 2.2));
    final faint = color.withValues(alpha: color.a * 0.35);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [bright, faint, faint, color],
      ).createShader(rect);
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _GlassRimPainter oldDelegate) =>
      oldDelegate.radius != radius || oldDelegate.color != color;
}

class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GlassAppBar({
    required this.title,
    super.key,
    this.actions,
    this.leading,
    this.blurEnabled = true,
  });

  final Widget title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool blurEnabled;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      padding: EdgeInsets.zero,
      radius: 0,
      blurEnabled: blurEnabled,
      tint: const Color(0x660B0B18),
      borderColor: Colors.white10,
      child: AppBar(
        title: title,
        actions: actions,
        leading: leading,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }
}

class GlassButton extends StatelessWidget {
  const GlassButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.filled = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: GlassSurface(
        padding: EdgeInsets.zero,
        radius: 14,
        blurSigma: 16,
        tint: filled
            ? AppColors.primary.withValues(alpha: 0.42)
            : const Color(0x33FFFFFF),
        borderColor: filled ? const Color(0x66FFFFFF) : const Color(0x40FFFFFF),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
