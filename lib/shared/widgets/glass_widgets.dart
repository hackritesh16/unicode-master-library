import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Reusable translucent surface with a no-blur fallback for low-power devices.
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(12),
    this.radius = 18,
    this.blurEnabled = true,
    this.tint = const Color(0xB8141420),
    this.borderColor = const Color(0x40FFFFFF),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool blurEnabled;
  final Color tint;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final shape = BorderRadius.circular(radius);
    final surface = DecoratedBox(
      decoration: BoxDecoration(
        color: tint,
        borderRadius: shape,
        border: Border.all(color: borderColor),
      ),
      child: Padding(padding: padding, child: child),
    );
    if (!blurEnabled) return ClipRRect(borderRadius: shape, child: surface);
    return ClipRRect(
      borderRadius: shape,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: surface,
      ),
    );
  }
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
      tint: const Color(0xC90B0B12),
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
    return GlassSurface(
      padding: EdgeInsets.zero,
      radius: 14,
      tint: filled
          ? AppColors.primary.withValues(alpha: 0.30)
          : const Color(0x661D1D2E),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 8),
              ],
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
