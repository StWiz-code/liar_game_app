import 'package:flutter/material.dart';
import 'game_session.dart';
import 'gpt_service.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final TextEditingController _controller = TextEditingController();
  GameSession? gameSession;

  // 라이어 추리 힌트 변수
  final GptService _gptService = GptService();
  String? _liarHintText;
  bool _isLiarHintLoading = false;

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

  // ## 제시어 설명 힌트 함수 추가 ##
  void _fetchWordHint() async {
    if (gameSession == null) return;

    // 현재 플레이어 정보 확인
    final currentPlayer = gameSession!.players[gameSession!.currentPlayerIndex];
    final isLiar = currentPlayer == gameSession!.liar;
    final word = isLiar ? gameSession!.liarWord : gameSession!.word;
    final topic = gameSession!.topic;

    // 로딩 팝업 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final hint = await _gptService.getWordHint(
        topic: topic,
        word: word,
        isLiar: isLiar,
      );

      // 로딩 팝업 닫기
      if (mounted) Navigator.of(context).pop();

      // 결과 팝업 표시
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('💡 AI 설명 힌트'),
            content: Text(hint),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('확인'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // 로딩 팝업 닫기
      if (mounted) Navigator.of(context).pop();
      // 에러 메시지 표시
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('힌트 생성에 실패했습니다: $e')));
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

  void _fetchLiarHint() async {
    if (gameSession == null) return;
    setState(() {
      _isLiarHintLoading = true;
      _liarHintText = null;
    });

    try {
      final hint = await _gptService.getLiarHint(gameSession!);
      setState(() {
        _liarHintText = hint;
      });
    } finally {
      setState(() {
        _isLiarHintLoading = false;
      });
    }
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
      appBar: AppBar(title: Text('주제: ${gameSession!.topic}')),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$currentPlayer 님의 설명 차례',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        // ## 설명 힌트 받기 버튼 추가 ##
                        IconButton(
                          icon: const Icon(Icons.lightbulb_outline),
                          onPressed: _fetchWordHint,
                          tooltip: 'AI에게 설명 힌트 받기',
                        ),
                      ],
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
                Column(
                  children: [
                    if (_isLiarHintLoading)
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    if (_liarHintText != null)
                      Card(
                        elevation: 2,
                        color: Colors.blue.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '🕵️ GPT 탐정의 추리',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(_liarHintText!),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed:
                                (_isLiarHintLoading || _liarHintText != null)
                                ? null
                                : _fetchLiarHint,
                            child: const Text('GPT 라이어 추리'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/voting',
                                arguments: gameSession,
                              );
                            },
                            child: const Text('투표 시작하기'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
