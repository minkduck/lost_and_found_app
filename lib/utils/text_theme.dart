import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lost_and_find_app/utils/app_styles.dart';
import 'package:lost_and_find_app/utils/colors.dart';

class TTextTheme {
  static TextTheme lightTextTheme = TextTheme(
    displayLarge: AppStyles.h1.copyWith(fontWeight: FontWeight.bold, color: AppColors.titleColor),
    headlineMedium: AppStyles.h2.copyWith(fontWeight: FontWeight.bold, color: AppColors.titleColor),
    displayMedium: AppStyles.h3.copyWith(color: AppColors.titleColor, fontWeight: FontWeight.bold),
    labelMedium: AppStyles.h4.copyWith(color: AppColors.titleColor),
    titleMedium: AppStyles.h5.copyWith(color: AppColors.titleColor, fontWeight: FontWeight.bold),
    labelSmall: AppStyles.h6.copyWith(color: Color(0xFFA4A9FC)),
    titleSmall: AppStyles.h6.copyWith(color: Color(0xFF2A2D64)),
    headlineSmall: AppStyles.h6.copyWith(color: Colors.black),

  );
  static TextTheme darkTextTheme = TextTheme(
    displayLarge: AppStyles.h1.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
    headlineMedium: AppStyles.h2.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
    displayMedium: AppStyles.h3.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
    labelMedium: AppStyles.h4.copyWith(color: Colors.white),
    titleMedium: AppStyles.h5.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
    labelSmall: AppStyles.h6.copyWith(color: Colors.grey),
    titleSmall: AppStyles.h6.copyWith(color: Colors.white),
    headlineSmall: AppStyles.h6.copyWith(color: Colors.white),

  );
}