import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'game_screen.dart'; // 새 화면 임포트

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomeScreen(), // 홈 화면 분리
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('라이어 게임'), backgroundColor: Colors.blue),
      body: Center(
        child: ElevatedButton(
          child: const Text('게임 시작'),
          onPressed: () {
            debugPrint('게임 시작 버튼 눌림!');
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const GameScreen()),
            ); // 게임 화면으로 이동
          },
        ),
      ),
    );
  }
}
