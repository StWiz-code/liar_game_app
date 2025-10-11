import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // GoogleFonts를 사용하기 위해 임포트
import 'app_colors.dart';

class AppTextStyles {
  // 모든 TextStyle을 GoogleFonts.gaegu()로 변경합니다.
  static TextStyle get headline1 => GoogleFonts.gaegu(
    fontSize: 30, // 손글씨 폰트는 크기를 살짝 키우는 것이 좋습니다.
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle get headline2 => GoogleFonts.gaegu(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle get body1 => GoogleFonts.gaegu(
    fontSize: 18,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle get button => GoogleFonts.gaegu(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static TextStyle get caption =>
      GoogleFonts.gaegu(fontSize: 15, color: AppColors.textSecondary);
}
