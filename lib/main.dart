import 'package:flutter/material.dart';
import 'game_screen.dart';
import 'player_setup_screen.dart';
import 'role_check_screen.dart';

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
        // StatelessWidget은 const로 선언할 수 있습니다.
        '/': (context) => const HomeScreen(),
        // 아래 StatefulWidget들은 const로 선언할 수 없으므로 const를 제거했습니다.
        '/player_setup': (context) => PlayerSetupScreen(),
        '/role_check': (context) => RoleCheckScreen(),
        '/game': (context) => GameScreen(),
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