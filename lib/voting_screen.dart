import 'package:flutter/material.dart';
import 'game_session.dart';
import 'gpt_service.dart'; // GPT 서비스 임포트
import 'core/theme/app_theme.dart'; // GradientButton 사용

class VotingScreen extends StatefulWidget {
  const VotingScreen({super.key});

  @override
  State<VotingScreen> createState() => _VotingScreenState();
}

class _VotingScreenState extends State<VotingScreen> {
  GameSession? gameSession;
  final GptService _gptService = GptService();

  int _currentVoterIndex = 0;
  bool _isAIVoting = false;
  String _statusMessage = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (gameSession == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is GameSession) {
        gameSession = args;
        // 위젯 빌드 후 첫 투표자 처리 시작
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _processNextVoter(),
        );
      }
    }
  }

  /// 다음 투표자를 처리하는 메인 로직
  Future<void> _processNextVoter() async {
    if (!mounted || gameSession == null) return;

    // 모든 투표가 끝났으면 결과 화면으로 이동
    if (_currentVoterIndex >= gameSession!.players.length) {
      Navigator.pushReplacementNamed(
        context,
        '/results',
        arguments: gameSession,
      );
      return;
    }

    final currentVoter = gameSession!.players[_currentVoterIndex];

    if (currentVoter.startsWith('AI')) {
      // AI 턴일 경우
      setState(() {
        _isAIVoting = true;
        _statusMessage = '$currentVoter 님이 투표 중입니다...';
      });

      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;

      final votedFor = await _gptService.castAIVote(gameSession!, currentVoter);
      _recordVote(votedFor);
    } else {
      // 사람 턴일 경우
      setState(() {
        _isAIVoting = false;
        _statusMessage = '$currentVoter 님, 라이어라고 생각하는 사람에게 투표하세요.';
      });
    }
  }

  /// 투표를 기록하고 다음 투표자로 넘어가는 함수
  void _recordVote(String votedFor) {
    if (!mounted) return;
    setState(() {
      gameSession!.votes.update(
        votedFor,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
      _currentVoterIndex++;
      _processNextVoter(); // 다음 투표자 처리
    });
  }

  @override
  Widget build(BuildContext context) {
    if (gameSession == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // 현재 투표자가 사람일 경우에만 투표 옵션을 보여줌
    final isHumanTurn =
        !_isAIVoting && _currentVoterIndex < gameSession!.players.length;
    final currentVoter = isHumanTurn
        ? gameSession!.players[_currentVoterIndex]
        : '';

    return Scaffold(
      appBar: AppBar(title: const Text('라이어 투표')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              if (_isAIVoting)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
              // 사람 턴일 때만 투표 버튼들을 보여줌
              if (isHumanTurn)
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 2.5,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: gameSession!.players.length,
                    itemBuilder: (context, index) {
                      final player = gameSession!.players[index];
                      final isSelf = player == currentVoter;
                      return GradientButton(
                        onPressed: isSelf ? null : () => _recordVote(player),
                        text: player,
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
