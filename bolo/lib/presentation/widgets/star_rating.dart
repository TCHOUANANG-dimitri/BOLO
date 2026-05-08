import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final double size;
  final bool showValue;

  const StarRating({
    super.key,
    required this.rating,
    this.size = 14,
    this.showValue = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, color: AppColors.starFilled, size: size),
        const SizedBox(width: 2),
        if (showValue)
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: size - 2,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              fontFamily: 'Poppins',
            ),
          ),
      ],
    );
  }
}

class StarRatingRow extends StatelessWidget {
  final double rating;
  final int count;
  final double starSize;

  const StarRatingRow({
    super.key,
    required this.rating,
    this.count = 5,
    this.starSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final filled = i < rating.floor();
        final half = !filled && i < rating;
        return Icon(
          filled
              ? Icons.star_rounded
              : half
                  ? Icons.star_half_rounded
                  : Icons.star_outline_rounded,
          color: (filled || half) ? AppColors.starFilled : AppColors.starEmpty,
          size: starSize,
        );
      }),
    );
  }
}
