import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class CategoryIcon extends StatelessWidget {
  final String iconPath;
  final double size;
  final Color? color;

  const CategoryIcon({
    super.key,
    required this.iconPath,
    this.size = 28,
    this.color,
  });

  IconData _getIcon(String path) {
    switch (path) {
      case 'home_person':
        return Icons.home_rounded;
      case 'events':
        return Icons.celebration_rounded;
      case 'beauty':
        return Icons.auto_awesome_rounded;
      case 'digital':
        return Icons.movie_creation_rounded;
      case 'influencer':
        return Icons.campaign_rounded;
      case 'repair':
        return Icons.build_rounded;
      case 'baby':
        return Icons.child_care_rounded;
      case 'cleaning':
        return Icons.cleaning_services_rounded;
      case 'cooking':
        return Icons.soup_kitchen_rounded;
      case 'garden':
        return Icons.yard_rounded;
      case 'music':
        return Icons.music_note_rounded;
      case 'photo':
        return Icons.photo_camera_rounded;
      case 'catering':
        return Icons.restaurant_rounded;
      case 'decor':
        return Icons.palette_rounded;
      case 'hair':
        return Icons.content_cut_rounded;
      case 'makeup':
        return Icons.face_rounded;
      case 'fashion':
        return Icons.checkroom_rounded;
      case 'nails':
        return Icons.spa_rounded;
      case 'camera':
        return Icons.camera_alt_rounded;
      case 'video':
        return Icons.videocam_rounded;
      case 'design':
        return Icons.draw_rounded;
      case 'editing':
        return Icons.video_settings_rounded;
      case 'content':
        return Icons.article_rounded;
      case 'blog':
        return Icons.edit_note_rounded;
      case 'plumber':
        return Icons.plumbing_rounded;
      case 'electric':
        return Icons.electrical_services_rounded;
      case 'carpenter':
        return Icons.handyman_rounded;
      case 'painter':
        return Icons.format_paint_rounded;
      case 'assistance':
        return Icons.accessible_rounded;
      case 'transport':
        return Icons.directions_car_rounded;
      case 'education':
        return Icons.school_rounded;
      case 'maintenance':
        return Icons.cleaning_services_rounded;
      case 'hostess':
        return Icons.emoji_people_rounded;
      case 'care':
        return Icons.volunteer_activism_rounded;
      case 'home_care':
        return Icons.home_rounded;
      case 'nurse':
        return Icons.medical_services_rounded;
      case 'wellness':
        return Icons.self_improvement_rounded;
      case 'driver':
        return Icons.drive_eta_rounded;
      case 'moving':
        return Icons.local_shipping_rounded;
      case 'delivery':
        return Icons.delivery_dining_rounded;
      case 'volunteer':
        return Icons.favorite_rounded;
      default:
        return Icons.miscellaneous_services_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return Icon(_getIcon(iconPath), size: size, color: c);
  }
}
