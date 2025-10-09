import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart'; // 디자인 시스템 테마 임포트
import 'game_screen.dart';
import 'player_setup_screen.dart';
import 'role_check_screen.dart';
import 'voting_screen.dart';
import 'results_screen.dart';

void main() {
  runApp(const LiarGameApp());
}

class LiarGameApp extends StatelessWidget {
  const LiarGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '라이어 게임',
      theme: AppTheme.lightTheme, // 앱 전체에 디자인 시스템 적용
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/player_setup': (context) => const PlayerSetupScreen(),
        '/role_check': (context) => const RoleCheckScreen(),
        '/game': (context) => const GameScreen(),
        '/voting': (context) => const VotingScreen(),
        '/results': (context) => const ResultsScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('라이어 게임', style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/player_setup');
                },
                child: const Text('게임 시작'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
