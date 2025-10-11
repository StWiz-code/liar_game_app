import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
// 1. Unused screen imports are removed as routing is now handled by AppRouter.
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
      debugShowCheckedModeBanner: false,
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
            const SizedBox(height: 40),
            SizedBox(
              width: 250,
              // 2. 'child' argument is moved to the end of the argument list.
              child: GradientButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/player_setup');
                },
                text: '게임 시작',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
