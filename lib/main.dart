import 'package:flutter/material.dart';
import 'game_screen.dart';
import 'player_setup_screen.dart';
import 'role_check_screen.dart';
import 'voting_screen.dart';   // VotingScreen 임포트
import 'results_screen.dart';  // ResultsScreen 임포트

void main() {
  runApp(const LiarGameApp());
}

class LiarGameApp extends StatelessWidget {
  const LiarGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '라이어 게임',
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/player_setup': (context) => PlayerSetupScreen(),
        '/role_check': (context) => RoleCheckScreen(),
        '/game': (context) => GameScreen(),
        // 아래 두 경로를 추가합니다.
        '/voting': (context) => VotingScreen(),
        '/results': (context) => ResultsScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('라이어 게임')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/player_setup');
          },
          child: const Text('게임 시작'),
        ),
      ),
    );
  }
}