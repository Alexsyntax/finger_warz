import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool filled;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.filled = true,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = filled
        ? ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          )
        : OutlinedButton.styleFrom(
            foregroundColor: AppTheme.textDark,
            side: const BorderSide(color: AppTheme.border),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          );

    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 10)],
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );

    return SizedBox(
      width: double.infinity,
      child: filled
          ? ElevatedButton(
              onPressed: onPressed,
              style: buttonStyle,
              child: child,
            )
          : OutlinedButton(
              onPressed: onPressed,
              style: buttonStyle,
              child: child,
            ),
    );
  }
}
