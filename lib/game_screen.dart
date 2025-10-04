import 'package:flutter/material.dart';
import 'game_session.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final TextEditingController _controller = TextEditingController();
  // 'late'를 제거하고 nullable 타입으로 변경
  GameSession? gameSession;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    if (gameSession == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is GameSession) {
        setState(() {
          gameSession = args;
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            // 안전하게 이전 화면으로 이동
            Navigator.of(context).pop();
          }
        });
      }
    }
  }

  void _submitDescription() {
    // gameSession이 null이면 아무 동작도 하지 않음
    if (gameSession == null) return;
    
    if (_controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('설명을 입력해주세요!')),
      );
      return;
    }

    setState(() {
      final currentPlayer =
          gameSession!.players[gameSession!.currentPlayerIndex];
      gameSession!.descriptions[currentPlayer] = _controller.text.trim();
      
      // 다음 플레이어로 턴을 넘김
      if (gameSession!.currentPlayerIndex < gameSession!.players.length - 1) {
        gameSession!.currentPlayerIndex++;
      } else {
        // 모든 플레이어가 설명을 마쳤음을 알림
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: const Text('설명 완료'),
                  content: const Text('모든 플레이어가 설명을 마쳤습니다. 투표를 시작하세요.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('확인'),
                    )
                  ],
                ));
      }
      _controller.clear();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // gameSession이 null일 경우 로딩 인디케이터를 보여줌
    if (gameSession == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    final currentPlayer = gameSession!.players[gameSession!.currentPlayerIndex];
    final allDescriptionsDone = gameSession!.descriptions.length == gameSession!.players.length;

    return Scaffold(
      appBar: AppBar(title: Text('주제: ${gameSession!.topic}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: gameSession!.descriptions.length,
                itemBuilder: (context, index) {
                  final player = gameSession!.descriptions.keys.elementAt(index);
                  final description = gameSession!.descriptions[player];
                  return Card(
                    child: ListTile(
                      title: Text(player),
                      subtitle: Text(description!),
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 32),
            if (!allDescriptionsDone)
              Column(
                children: [
                  Text(
                    '$currentPlayer 님의 설명 차례',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '제시어 설명 입력',
                    ),
                    onSubmitted: (_) => _submitDescription(),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _submitDescription,
                    child: const Text('설명 제출'),
                  ),
                ],
              )
            else
              ElevatedButton(
                onPressed: () {
                  // TODO: 투표 기능 구현
                },
                child: const Text('투표 시작하기'),
              )
          ],
        ),
      ),
    );
  }
}