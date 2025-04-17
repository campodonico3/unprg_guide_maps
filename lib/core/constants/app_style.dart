import 'package:flutter/material.dart';
import 'package:unprg_guide_maps/core/constants/app_colors.dart';

class AppTextStyles {
  // Privado para evitar instanciación
  AppTextStyles._();

  static const TextStyle black = TextStyle(
    fontFamily: 'Nunito',
    fontWeight: FontWeight.w900,
    fontSize: 32,
  );

  static const TextStyle bold = TextStyle(
    fontFamily: 'Nunito',
    fontWeight: FontWeight.w700,
    fontSize: 24,
    color: AppColors.textOnPrimary,
  );

  static const TextStyle medium = TextStyle(
    fontFamily: 'Nunito',
    fontWeight: FontWeight.w500,
    fontSize: 20,
  );

  static const TextStyle regular = TextStyle(
    fontFamily: 'Nunito',
    fontWeight: FontWeight.w400,
    fontSize: 16,
  );

  static const TextStyle light = TextStyle(
    fontFamily: 'Nunito',
    fontWeight: FontWeight.w300,
    fontSize: 14,
  );
}