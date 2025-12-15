import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Provider 패키지 임포트 필요
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'core/router.dart';
import 'services/nearby_service.dart'; // NearbyService 임포트

void main() {
  runApp(const LiarGameApp());
}

class LiarGameApp extends StatelessWidget {
  const LiarGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider로 감싸서 하위 위젯 어디서든 NearbyService에 접근 가능하게 함
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NearbyService()),
      ],
      child: MaterialApp(
        title: '라이어 게임',
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        onGenerateRoute: AppRouter.generateRoute,
        debugShowCheckedModeBanner: false, // 디버그 배너 제거
      ),
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
