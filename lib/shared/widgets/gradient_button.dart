import 'package:flutter/material.dart';
import '../../themes/app_theme.dart';

/// A beautiful gradient button used throughout the app
class GradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final LinearGradient gradient;
  final Color textColor;
  final bool isLoading;
  final double height;
  final double borderRadius;

  const GradientButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.gradient = AppTheme.goldGradient,
    this.textColor = Colors.black,
    this.isLoading = false,
    this.height = 58,
    this.borderRadius = 18,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          gradient: onPressed == null ? null : gradient,
          color: onPressed == null ? AppTheme.borderGlass : null,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: onPressed == null
              ? null
              : [
                  BoxShadow(
                    color: gradient.colors.first.withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(textColor),
                  ),
                )
              : Text(
                  text,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: onPressed == null
                            ? AppTheme.textSecondary
                            : textColor,
                        fontSize: 15,
                        letterSpacing: 1.5,
                      ),
                ),
        ),
      ),
    );
  }
}
