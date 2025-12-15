import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // HapticFeedback을 위해 임포트
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.secondary,
    fontFamily: GoogleFonts.gaegu().fontFamily,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.accentEmerald,
      surface: AppColors.secondary,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTextStyles.headline2.copyWith(
        color: AppColors.primary,
      ),
      iconTheme: const IconThemeData(color: AppColors.primary),
    ),
    textTheme: TextTheme(
      headlineLarge: AppTextStyles.headline1,
      headlineSmall: AppTextStyles.headline2,
      bodyLarge: AppTextStyles.body1,
      labelLarge: AppTextStyles.button,
      bodySmall: AppTextStyles.caption,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 2),
        textStyle: AppTextStyles.button.copyWith(color: AppColors.primary),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        // [수정] const 추가 (성능 최적화)
        side: const BorderSide(color: AppColors.glass, width: 1.5),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
    ),
  );
}

// 그라데이션 버튼 커스텀 위젯
class GradientButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String text;
  final TextStyle? textStyle;
  final Gradient? gradient;

  const GradientButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.textStyle,
    this.gradient,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      setState(() => _scale = 0.95);
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed != null) {
      setState(() => _scale = 1.0);
      widget.onPressed!();
      HapticFeedback.lightImpact();
    }
  }

  void _onTapCancel() {
    setState(() => _scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    // [수정] final -> const 변경 (변수 자체가 상수임을 명시)
    const defaultGradient = LinearGradient(
      colors: [AppColors.primary, AppColors.accentViolet],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 150),
        child: Container(
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: widget.onPressed == null
                ? const LinearGradient(colors: [Colors.grey, Colors.grey])
                : widget.gradient ?? defaultGradient,
            borderRadius: BorderRadius.circular(30),
            boxShadow: widget.onPressed == null
                ? []
                : [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(77),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
          ),
          child: Text(
            widget.text,
            style: widget.textStyle ?? AppTextStyles.button,
          ),
        ),
      ),
    );
  }
}
