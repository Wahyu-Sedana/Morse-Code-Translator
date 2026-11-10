import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class SquareIconButton extends StatelessWidget {
  const SquareIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.size = 44,
    this.radius = 14,
    this.background = AppColors.surface,
    this.foreground = AppColors.ink,
    this.bordered = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final double size;
  final double radius;
  final Color background;
  final Color foreground;
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: bordered ? const BorderSide(color: AppColors.border) : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(icon, size: 20, color: foreground, semanticLabel: tooltip),
          ),
        ),
      ),
    );
  }
}
