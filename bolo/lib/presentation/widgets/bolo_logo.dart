import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class BoloLogo extends StatelessWidget {
  final double size;
  final bool showText;

  const BoloLogo({super.key, this.size = 80, this.showText = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(size * 0.25),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(size * 0.18),
            child: Image.asset(
              'assets/images/logo_white.png',
              color: Colors.white,
              errorBuilder: (_, __, ___) => Icon(
                Icons.location_on_rounded,
                color: Colors.white,
                size: size * 0.55,
              ),
            ),
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 8),
          Text(
            'BOLO',
            style: AppTextStyles.headlineLarge.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
        ],
      ],
    );
  }
}
