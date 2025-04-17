import 'package:flutter/material.dart';
import 'package:unprg_guide_maps/core/constants/app_colors.dart';
import 'package:unprg_guide_maps/core/constants/app_style.dart';

class SearchBarWidget extends StatelessWidget {
  final Function(String) onSearchChanged;
  final TextEditingController controller;

  const SearchBarWidget({
    super.key,
    required this.onSearchChanged,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Buscar facultad, oficina o aula...',
          hintStyle: AppTextStyles.light.copyWith(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
          /*TextStyle(color: AppColors.textSecondary),*/
          prefixIcon: Icon(Icons.search, color: AppColors.primary),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear, color: AppColors.primary),
            onPressed: () {
              controller.clear();
              onSearchChanged('');
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}
