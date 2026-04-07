import 'package:flutter/material.dart';
import 'app_colors.dart';

// Jost is the font used on pashtuncollections.in
// Using system sans-serif fallback; add google_fonts if needed
class AppTextStyles {
  AppTextStyles._();

  static const String _heading = 'Jost';
  static const String _body = 'Jost';

  static const displayLarge  = TextStyle(fontFamily: _heading, fontSize: 34, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.2, letterSpacing: -0.5);
  static const displayMedium = TextStyle(fontFamily: _heading, fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.25);
  static const headlineLarge = TextStyle(fontFamily: _heading, fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.3);
  static const headlineMedium= TextStyle(fontFamily: _heading, fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.3);
  static const titleLarge    = TextStyle(fontFamily: _heading, fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary, letterSpacing: 0.5);
  static const bodyLarge     = TextStyle(fontFamily: _body,    fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textPrimary, height: 1.6);
  static const bodyMedium    = TextStyle(fontFamily: _body,    fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textPrimary, height: 1.6);
  static const bodySmall     = TextStyle(fontFamily: _body,    fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textSecondary, height: 1.5);
  static const labelLarge    = TextStyle(fontFamily: _body,    fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary, letterSpacing: 0.3);
  static const labelMedium   = TextStyle(fontFamily: _body,    fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary, letterSpacing: 0.2);
  static const labelSmall    = TextStyle(fontFamily: _body,    fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecondary, letterSpacing: 0.4);
  static const buttonText    = TextStyle(fontFamily: _body,    fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 1.2);
  static const priceTag      = TextStyle(fontFamily: _body,    fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary);
  static const priceSale     = TextStyle(fontFamily: _body,    fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textSecondary, decoration: TextDecoration.lineThrough);
}
