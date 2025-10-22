import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart'; // 색상 사용을 위해 임포트
import 'core/router.dart';

void main() {
  runApp(const LiarGameApp());
}

class LiarGameApp extends StatelessWidget {
  const LiarGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '라이어 게임',
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('라이어 게임', style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 50),
            // '혼자하기' 버튼
            SizedBox(
              width: 250,
              child: GradientButton(
                onPressed: () {
                  // '/single_player_setup' 경로는 2단계에서 만듭니다.
                  Navigator.pushNamed(context, '/single_player_setup');
                },
                text: '🤖 혼자하기 (AI 대전)',
              ),
            ),
            const SizedBox(height: 20),
            // '함께하기' 버튼
            SizedBox(
              width: 250,
              child: GradientButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/player_setup');
                },
                text: '👥 함께하기',
                // 핑크 그라데이션으로 차별화
                gradient: const LinearGradient(
                  colors: [AppColors.accentPink, AppColors.accentLightPink],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
