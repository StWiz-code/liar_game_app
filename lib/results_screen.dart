import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_text_styles.dart';
import 'game_session.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  late ConfettiController _winConfettiController;
  late ConfettiController _loseConfettiController;

  GameSession? gameSession;

  bool? liarCaught;
  String? winnerText;
  Color? winnerColor;
  List<String> mostVotedPlayers = [];

  @override
  void initState() {
    super.initState();
    _winConfettiController = ConfettiController(
      duration: const Duration(seconds: 1),
    );
    _loseConfettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final args = ModalRoute.of(context)?.settings.arguments;
        if (args is GameSession) {
          gameSession = args;
          _calculateResults();
        }
      }
    });
  }

  void _calculateResults() {
    if (gameSession == null) return;

    int maxVotes = 0;
    if (gameSession!.votes.isNotEmpty) {
      gameSession!.votes.forEach((player, votes) {
        if (votes > maxVotes) {
          maxVotes = votes;
          mostVotedPlayers = [player];
        } else if (votes == maxVotes) {
          mostVotedPlayers.add(player);
        }
      });
    }

    final bool tie = mostVotedPlayers.length > 1;
    final bool isLiarCaught =
        mostVotedPlayers.length == 1 &&
        mostVotedPlayers.first == gameSession!.liar;

    setState(() {
      liarCaught = isLiarCaught;
      if (liarCaught!) {
        winnerText = '시민 승리!';
        winnerColor = AppColors.accentEmerald;
        _winConfettiController.play();
      } else {
        winnerText = tie ? '라이어 승리! (동점)' : '라이어 승리!';
        winnerColor = AppColors.primary;
        _loseConfettiController.play();
      }
    });
  }

  @override
  void dispose() {
    _winConfettiController.dispose();
    _loseConfettiController.dispose();
    super.dispose();
  }

  void _restartGame() {
    if (gameSession == null) return;
    final newSession = GameSession(players: gameSession!.players);
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/role_check',
      (route) => false,
      arguments: newSession,
    );
  }

  void _goToHome() {
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (winnerText == null || gameSession == null) {
      return const Scaffold(
        backgroundColor: AppColors.secondary,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: liarCaught!
          ? AppColors.winBackground
          : AppColors.loseBackground,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        winnerText!,
                        textAlign: TextAlign.center,
                        style: textTheme.headlineLarge?.copyWith(
                          color: winnerColor,
                          fontSize: 36,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildResultInfoCard(textTheme),
                      const SizedBox(height: 32),
                      Text(
                        '투표 결과',
                        textAlign: TextAlign.center,
                        style: textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      _buildVoteResultsChart(textTheme),
                      const SizedBox(height: 40),
                      GradientButton(
                        onPressed: _restartGame,
                        text: '같은 멤버로 다시하기',
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: _goToHome,
                        child: const Text('처음으로'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // 시민 승리 시 폭죽 효과 (변경 없음)
          ConfettiWidget(
            confettiController: _winConfettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              AppColors.primary,
              AppColors.accentViolet,
              AppColors.accentEmerald,
            ],
          ),
          // ## 라이어 승리 시 '어둠의 비' 효과 (수정됨) ##
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _loseConfettiController,
              blastDirectionality: BlastDirectionality.directional,
              blastDirection: pi / 2, // 아래 방향
              emissionFrequency: 0.01, // 더 촘촘하게
              numberOfParticles: 25, // 입자 수 증가
              maxBlastForce: 20, // 넓게 퍼지도록
              minBlastForce: 5, // 약하게도 섞이도록
              gravity: 0.2, // 천천히 떨어지도록
              shouldLoop: false,
              colors: const [
                // 색상 변경
                AppColors.primary,
                AppColors.accentViolet,
                Color(0xFF8B0000), // 어두운 핏빛 (Crimson)
                Colors.black87,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultInfoCard(TextTheme textTheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('라이어', style: textTheme.bodyLarge),
                Text(
                  gameSession!.liar,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('시민 제시어', style: textTheme.bodyLarge),
                Text(
                  gameSession!.word,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoteResultsChart(TextTheme textTheme) {
    if (gameSession!.votes.isEmpty) {
      return Center(child: Text('투표가 진행되지 않았습니다.', style: textTheme.bodyLarge));
    }

    final barGroups = <BarChartGroupData>[];
    int i = 0;
    for (var player in gameSession!.players) {
      final voteCount = gameSession!.votes[player] ?? 0;
      barGroups.add(
        BarChartGroupData(
          x: i++,
          barRods: [
            BarChartRodData(
              toY: voteCount.toDouble(),
              gradient: const LinearGradient(
                colors: [AppColors.accentViolet, AppColors.primary],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
              width: 22,
              borderRadius: BorderRadius.circular(6),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 150,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barGroups: barGroups,
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  final text = Text(
                    gameSession!.players[value.toInt()],
                    style: textTheme.bodySmall,
                  );
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    angle: -0.785,
                    child: text,
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${rod.toY.toInt()}표',
                  AppTextStyles.button.copyWith(fontSize: 14),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
