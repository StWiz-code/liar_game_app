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

  // 화면에 필요한 데이터가 변경될 때 호출되는 부분입니다.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // gameSession 데이터는 여기서 한 번만 설정합니다.
    if (gameSession == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      print('🟠 RoleCheckScreen에서 데이터 수신 시도: $args'); // 디버깅용 print
      if (args != null && args is GameSession) {
        setState(() {
          gameSession = args;
        });
      } else {
        // 데이터가 없으면 이전 화면으로 돌아갑니다.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      }
    }
  }

  void _flipCard() {
    // 카드가 이미 뒤집혔거나 애니메이션이 진행 중이면 아무것도 하지 않습니다.
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
        _isCardFlipped = false; // 다음 플레이어를 위해 카드 상태 초기화
        _animationController.reset(); // 애니메이션 컨트롤러 초기화
      });
    } else {
      // 마지막 플레이어라면 게임 화면으로 이동
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
    // 데이터가 아직 준비되지 않았다면 로딩 화면을 보여줍니다.
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
                    // 3D 회전 효과
                    final transform = Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(angle);

                    return Transform(
                      transform: transform,
                      alignment: Alignment.center,
                      child: isFrontSide
                          ? _buildCardFront()
                          : Transform(
                              // 뒷면은 반대로 뒤집어서 보여줌
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
                // 카드를 뒤집어야만 버튼이 활성화됩니다.
                onPressed: _isCardFlipped ? _nextPlayer : null,
                child: Text(isLastPlayer ? '모두 확인! 게임 시작' : '다음 플레이어'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 카드 앞면 UI
  Widget _buildCardFront() {
    return Card(
      child: Container(
        height: 250,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Theme.of(context).primaryColor, Colors.purple.shade300],
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

  // 카드 뒷면 UI
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
              isLiar ? '주제만 보고 정체를 숨기세요!' : '제시어를 확인하세요!',
              style: theme.textTheme.bodySmall,
            ),
            const Divider(height: 32),
            Text(
              isLiar ? session.topic : session.word,
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
