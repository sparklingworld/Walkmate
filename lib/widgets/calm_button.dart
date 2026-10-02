import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum CalmButtonStyle {
  primary,
  secondary,
  outline,
  terracotta,
}

class CalmButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final CalmButtonStyle style;
  final bool isLoading;

  const CalmButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.style = CalmButtonStyle.primary,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    BorderSide border = BorderSide.none;

    switch (style) {
      case CalmButtonStyle.primary:
        bg = AppColors.primary;
        fg = Colors.white;
        break;
      case CalmButtonStyle.secondary:
        bg = AppColors.primarySoft;
        fg = AppColors.primary;
        break;
      case CalmButtonStyle.terracotta:
        bg = AppColors.accentPeach;
        fg = Colors.white;
        break;
      case CalmButtonStyle.outline:
        bg = Colors.transparent;
        fg = AppColors.textDark;
        border = const BorderSide(color: AppColors.divider, width: 1.5);
        break;
    }

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.fromBorderSide(border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(fg),
                  ),
                )
              else if (icon != null) ...[
                Icon(icon, size: 18, color: fg),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
