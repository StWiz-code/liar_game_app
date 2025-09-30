import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final _controller = TextEditingController(); // 입력란 컨트롤러
  String _answer = ''; // 입력된 답변 저장
  final List<String> _topics = ['동물', '음식', '직업']; // 주제 목록
  String _currentTopic = '동물'; // 현재 주제

  @override
  void dispose() {
    _controller.dispose(); // 메모리 정리
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('게임 화면'), backgroundColor: Colors.green),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '주제: $_currentTopic',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '답변 입력',
              ),
              onChanged: (value) {
                setState(() {
                  _answer = value; // 입력값 저장
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('답변 제출'),
              onPressed: () {
                if (_answer.isNotEmpty) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('제출된 답변: $_answer')));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
