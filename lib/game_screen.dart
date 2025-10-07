import 'package:flutter/material.dart';
import 'game_session.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key}); // 'const' 추가

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final TextEditingController _controller = TextEditingController();
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
            Navigator.of(context).pop();
          }
        });
      }
    }
  }

  void _submitDescription() {
    if (gameSession == null) return;

    if (_controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('설명을 입력해주세요!')));
      return;
    }

    setState(() {
      final currentPlayer =
          gameSession!.players[gameSession!.currentPlayerIndex];
      gameSession!.descriptions[currentPlayer] = _controller.text.trim();

      if (gameSession!.currentPlayerIndex < gameSession!.players.length - 1) {
        gameSession!.currentPlayerIndex++;
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
    if (gameSession == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final allDescriptionsDone =
        gameSession!.descriptions.length == gameSession!.players.length;
    final currentPlayer = gameSession!.players[gameSession!.currentPlayerIndex];

    return Scaffold(
      // 불필요한 중괄호 제거
      appBar: AppBar(title: Text('주제: $gameSession!.topic')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: gameSession!.descriptions.length,
                  itemBuilder: (context, index) {
                    final player = gameSession!.descriptions.keys.elementAt(
                      index,
                    );
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
                    Navigator.pushNamed(
                      context,
                      '/voting',
                      arguments: gameSession,
                    );
                  },
                  child: const Text('투표 시작하기'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
