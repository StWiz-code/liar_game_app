import 'package:flutter/material.dart';
import 'game_screen.dart';
import 'player_setup_screen.dart';
import 'role_check_screen.dart';
import 'voting_screen.dart';
import 'results_screen.dart';

void main() {
  runApp(const LiarGameApp());
}

class LiarGameApp extends StatelessWidget {
  const LiarGameApp({super.key}); // 'const' 추가

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '라이어 게임',
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
  const HomeScreen({super.key}); // 'const' 추가

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('라이어 게임')),
      body: SafeArea(
        child: Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/player_setup');
            },
            child: const Text('게임 시작'),
          ),
        ),
      ),
    );
  }
}
