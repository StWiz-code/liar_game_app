import 'package:flutter/material.dart';
import 'app_colors.dart';

// 앱에서 사용할 텍스트 스타일을 미리 정의합니다.
class AppTextStyles {
  // 'GoogleFonts.pretendard' 대신 'TextStyle(fontFamily: 'Pretendard')'로 수정합니다.
  static TextStyle get headline1 => const TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  static TextStyle get headline2 => const TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  static TextStyle get body1 => const TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 16,
    color: AppColors.textPrimary,
    height: 1.5,
  );
  static TextStyle get button => const TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  static TextStyle get caption => const TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 14,
    color: AppColors.textSecondary,
  );
}
