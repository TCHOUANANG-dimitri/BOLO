import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class BoloLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool onDark; // true = fond sombre, affiche la version blanche

  const BoloLogo({
    super.key,
    this.size = 80,
    this.showText = false,
    this.onDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => _fallback(),
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 8),
          Text(
            'BOLO',
            style: AppTextStyles.headlineLarge.copyWith(
              color: onDark ? Colors.white : AppColors.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
        ],
      ],
    );
  }

  Widget _fallback() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(size * 0.25),
      ),
      child: Icon(
        Icons.location_on_rounded,
        color: Colors.white,
        size: size * 0.55,
      ),
    );
  }
}
