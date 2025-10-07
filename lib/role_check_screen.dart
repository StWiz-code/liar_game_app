import 'package:flutter/material.dart';
import 'game_session.dart';

class RoleCheckScreen extends StatefulWidget {
  // const 생성자가 아니므로 super.key를 전달하는 방식으로 변경합니다.
  RoleCheckScreen({super.key});

  @override
  State<RoleCheckScreen> createState() => _RoleCheckScreenState();
}

class _RoleCheckScreenState extends State<RoleCheckScreen> {
  GameSession? gameSession;
  int currentPlayerIndex = 0;
  bool isRoleVisible = false;

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

  void _showRole() {
    setState(() {
      isRoleVisible = true;
    });
  }

  void _nextPlayer() {
    if (gameSession == null) return;

    if (currentPlayerIndex < gameSession!.players.length - 1) {
      setState(() {
        currentPlayerIndex++;
        isRoleVisible = false;
      });
    } else {
      Navigator.pushReplacementNamed(context, '/game', arguments: gameSession);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (gameSession == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentPlayer = gameSession!.players[currentPlayerIndex];
    final isLiar = (currentPlayer == gameSession!.liar);
    final isLastPlayer =
        (currentPlayerIndex == gameSession!.players.length - 1);

    return Scaffold(
      appBar: AppBar(title: const Text('역할 확인')),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$currentPlayer 님의 차례입니다',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 32),
                isRoleVisible
                    ? Card(
                        elevation: 4,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(40.0),
                          child: Column(
                            children: [
                              Text(
                                isLiar ? '당신은 라이어입니다' : '제시어',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 16),
                              // ## 이 부분이 수정되었습니다! ##
                              // 라이어일 경우 topic 대신 liarWord를 보여줍니다.
                              Text(
                                isLiar
                                    ? gameSession!.liarWord
                                    : gameSession!.word,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      )
                    : GestureDetector(
                        onTap: _showRole,
                        child: Card(
                          elevation: 4,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(40.0),
                            child: Center(
                              child: Text(
                                '탭하여 역할 확인하기',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall,
                              ),
                            ),
                          ),
                        ),
                      ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _nextPlayer,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 16,
                    ),
                  ),
                  child: Text(isLastPlayer ? '게임 시작' : '확인 완료 (다음)'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
