import 'package:flutter/material.dart';
import 'package:unprg_guide_maps/core/constants/app_colors.dart';

class LocationMarker extends StatelessWidget {
  final String title;
  final bool isSelected;

  const LocationMarker({
    super.key,
    required this.title,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.neutral,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: const Icon(
            Icons.location_on,
            color: Colors.white,
            size: 24,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isSelected ? AppColors.primary : AppColors.neutral,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}