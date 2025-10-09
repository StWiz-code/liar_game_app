import 'dart:math';
import 'package:flutter/material.dart';
import 'game_session.dart';

class RoleCheckScreen extends StatefulWidget {
  const RoleCheckScreen({super.key});

  @override
  State<RoleCheckScreen> createState() => _RoleCheckScreenState();
}

class _RoleCheckScreenState extends State<RoleCheckScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isCardFlipped = false;

  GameSession? gameSession;
  int currentPlayerIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

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

  void _flipCard() {
    if (_isCardFlipped || _animationController.isAnimating) return;
    _animationController.forward();
    setState(() {
      _isCardFlipped = true;
    });
  }

  void _nextPlayer() {
    if (gameSession == null) return;
    final isLastPlayer = currentPlayerIndex == gameSession!.players.length - 1;
    if (!isLastPlayer) {
      setState(() {
        currentPlayerIndex++;
        _isCardFlipped = false;
        _animationController.reset();
      });
    } else {
      Navigator.pushReplacementNamed(context, '/game', arguments: gameSession);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (gameSession == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentPlayer = gameSession!.players[currentPlayerIndex];
    final isLiar = currentPlayer == gameSession!.liar;
    final isLastPlayer = currentPlayerIndex == gameSession!.players.length - 1;

    return Scaffold(
      appBar: AppBar(title: const Text('역할 확인')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '$currentPlayer 님의 차례',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 16),
              Text(
                '카드를 탭하여 역할을 확인하세요',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: _flipCard,
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    final angle = _animationController.value * pi;
                    final isFrontSide = _animationController.value < 0.5;
                    final transform = Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(angle);
                    return Transform(
                      transform: transform,
                      alignment: Alignment.center,
                      child: isFrontSide
                          ? _buildCardFront()
                          : Transform(
                              transform: Matrix4.identity()..rotateY(pi),
                              alignment: Alignment.center,
                              child: _buildCardBack(isLiar, gameSession!),
                            ),
                    );
                  },
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _isCardFlipped ? _nextPlayer : null,
                child: Text(isLastPlayer ? '모두 확인! 게임 시작' : '다음 플레이어'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardFront() {
    return Card(
      child: Container(
        height: 250,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          // 파란색 계열 그라데이션으로 수정
          gradient: LinearGradient(
            colors: [Theme.of(context).primaryColor, Colors.blue.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Center(
          child: Icon(
            Icons.question_mark_rounded,
            color: Colors.white,
            size: 80,
          ),
        ),
      ),
    );
  }

  Widget _buildCardBack(bool isLiar, GameSession session) {
    final theme = Theme.of(context);
    return Card(
      child: Container(
        height: 250,
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isLiar ? Icons.theater_comedy : Icons.person_search,
              size: 40,
              color: theme.primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              isLiar ? '당신은 라이어입니다' : '당신은 시민입니다',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              isLiar ? '정체를 숨기고 시민들을 속이세요!' : '제시어를 확인하세요!',
              style: theme.textTheme.bodySmall,
            ),
            const Divider(height: 32),
            Text(
              // ## 버그 수정: 라이어일 경우 session.topic 대신 session.liarWord를 보여줍니다.
              isLiar ? session.liarWord : session.word,
              style: theme.textTheme.headlineLarge?.copyWith(
                color: theme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
