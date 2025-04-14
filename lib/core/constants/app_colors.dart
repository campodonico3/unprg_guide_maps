import 'package:flutter/material.dart';

class AppColors {
  AppColors._();
  
  // Colores primarios de la aplicación
  static const Color primary = Color(0xFF2873B4); // #2873b4
  static const Color secondary = Color(0xFF7BD3E7); // #7bd3e7
  static const Color accent = Color(0xFFFFC300); // #ffc300
  static const Color neutral = Color(0xFF747474); // #747474
  
  // Variantes claras y oscuras (puedes expandir según necesites)
  static const Color primaryLight = Color(0xFF4A8FCB);
  static const Color primaryDark = Color(0xFF1A5A95);
  
  // Colores de fondo
  static const Color background = Colors.white;
  static const Color surface = Color(0xFFF5F5F5);
  
  // Colores de texto
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textOnPrimary = Colors.white;
  
  // Colores de estado
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFB300);
  static const Color info = Color(0xFF2196F3);
}