import 'package:flutter/material.dart';
import 'game_session.dart';
import 'gpt_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_text_styles.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  GameSession? gameSession;
  final TextEditingController _descriptionController = TextEditingController();
  final GptService _gptService = GptService();

  bool _allDescriptionsSubmitted = false;
  bool _isLiarHintLoading = false;
  bool _isWordHintLoading = false;
  bool _isAITurnProcessing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (gameSession == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is GameSession) {
        gameSession = args;
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _checkAndProcessAITurn(),
        );
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) Navigator.of(context).pop();
        });
      }
    }
  }

  Future<void> _checkAndProcessAITurn() async {
    if (gameSession == null || _allDescriptionsSubmitted || !mounted) return;

    final currentPlayer = gameSession!.players[gameSession!.currentPlayerIndex];
    if (currentPlayer.startsWith('AI')) {
      setState(() => _isAITurnProcessing = true);

      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;

      // 이전에 AI가 했던 설명들만 필터링해서 리스트 생성
      final previousAIDescriptions = gameSession!.descriptions.entries
          .where((entry) => entry.key.startsWith('AI'))
          .map((entry) => entry.value)
          .toList();

      final isLiar = currentPlayer == gameSession!.liar;
      final aiDescription = await _gptService.generateAIDescription(
        playerName: currentPlayer,
        topic: gameSession!.topic,
        word: isLiar ? gameSession!.liarWord : gameSession!.word,
        isLiar: isLiar,
        previousDescriptions: previousAIDescriptions, // 필터링된 리스트를 전달
      );

      if (mounted) {
        _submitDescription(aiDescription);
      }
    } else {
      setState(() => _isAITurnProcessing = false);
    }
  }

  void _submitDescription(String description) {
    if (description.trim().isEmpty) return;

    final currentPlayer = gameSession!.players[gameSession!.currentPlayerIndex];
    setState(() {
      gameSession!.descriptions[currentPlayer] = description.trim();
      _descriptionController.clear();
      gameSession!.currentPlayerIndex++;

      if (gameSession!.descriptions.length >= gameSession!.players.length) {
        _allDescriptionsSubmitted = true;
      } else {
        _checkAndProcessAITurn();
      }
    });
  }

  // --- 힌트 및 투표 시작 함수 (이전과 동일) ---
  Future<void> _showLiarHint() async {
    setState(() => _isLiarHintLoading = true);
    final hint = await _gptService.getLiarHint(gameSession!);
    if (!mounted) return;
    setState(() => _isLiarHintLoading = false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI의 라이어 분석'),
        content: Text(hint),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  Future<void> _showWordHint() async {
    setState(() => _isWordHintLoading = true);
    final currentPlayer = gameSession!.players[gameSession!.currentPlayerIndex];
    final isLiar = currentPlayer == gameSession!.liar;
    final hint = await _gptService.getWordHint(
      topic: gameSession!.topic,
      word: isLiar ? gameSession!.liarWord : gameSession!.word,
      isLiar: isLiar,
    );
    if (!mounted) return;
    setState(() => _isWordHintLoading = false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI 설명 힌트'),
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

  void _startVoting() {
    Navigator.pushReplacementNamed(context, '/voting', arguments: gameSession);
  }

  @override
  Widget build(BuildContext context) {
    if (gameSession == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text('주제: ${gameSession!.topic}')),
      body: _allDescriptionsSubmitted
          ? _buildPreVotingUI()
          : _buildDescriptionInputUI(),
    );
  }

  Widget _buildDescriptionInputUI() {
    if (gameSession!.currentPlayerIndex >= gameSession!.players.length) {
      return const Center(child: CircularProgressIndicator());
    }
    final currentPlayer = gameSession!.players[gameSession!.currentPlayerIndex];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: _isAITurnProcessing
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 20),
                    Text(
                      '$currentPlayer 님이 생각 중입니다...',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '$currentPlayer 님의 차례',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '제시어를 한 문장으로 설명해주세요.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      hintText: '예) 하늘을 나는 탈 것입니다.',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    textAlign: TextAlign.center,
                    onSubmitted: (_) =>
                        _submitDescription(_descriptionController.text),
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.lightbulb_outline),
                    label: Text(
                      _isWordHintLoading ? 'AI 생각 중...' : 'AI 설명 힌트 보기',
                    ),
                    onPressed: _isWordHintLoading ? null : _showWordHint,
                  ),
                  const Spacer(),
                  GradientButton(
                    onPressed: () =>
                        _submitDescription(_descriptionController.text),
                    text: '설명 제출',
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildPreVotingUI() {
    final smallButtonTextStyle = AppTextStyles.button.copyWith(fontSize: 15);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '모든 설명이 끝났습니다!\n토론 후 라이어를 지목해주세요.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '각 플레이어의 설명',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const Divider(height: 24),
                      Expanded(
                        child: ListView.builder(
                          itemCount: gameSession!.descriptions.length,
                          itemBuilder: (context, index) {
                            final player = gameSession!.descriptions.keys
                                .elementAt(index);
                            final description =
                                gameSession!.descriptions[player];
                            return ListTile(
                              leading: const Icon(Icons.comment_outlined),
                              title: Text(
                                player,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              subtitle: Text('"$description"'),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GradientButton(
                    onPressed: _isLiarHintLoading ? null : _showLiarHint,
                    text: _isLiarHintLoading ? '분석 중...' : 'AI 라이어 분석',
                    textStyle: smallButtonTextStyle,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GradientButton(
                    onPressed: _startVoting,
                    text: '투표 시작하기',
                    textStyle: smallButtonTextStyle,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
