import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class ProviderAvatar extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final double size;
  final double? borderRadius;

  const ProviderAvatar({
    super.key,
    required this.name,
    this.avatarUrl,
    this.size = 50,
    this.borderRadius,
  });

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  Color get _bgColor {
    final colors = [
      const Color(0xFFFB772C),
      const Color(0xFFFC6B5A),
      const Color(0xFF6C63FF),
      const Color(0xFF22C55E),
      const Color(0xFF3B82F6),
      const Color(0xFFF59E0B),
    ];
    final idx = name.codeUnitAt(0) % colors.length;
    return colors[idx];
  }

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius != null
        ? BorderRadius.circular(borderRadius!)
        : BorderRadius.circular(size * 0.3);

    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: radius,
        child: Image.network(
          avatarUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildInitials(radius),
        ),
      );
    }

    return _buildInitials(radius);
  }

  Widget _buildInitials(BorderRadius radius) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _bgColor.withOpacity(0.15),
        borderRadius: radius,
      ),
      child: Center(
        child: Text(
          _initials,
          style: AppTextStyles.titleMedium.copyWith(
            color: _bgColor,
            fontSize: size * 0.35,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
