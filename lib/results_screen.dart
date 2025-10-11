import 'package:confetti/confetti.dart'; // 이 라인이 추가되었습니다.
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'core/theme/app_colors.dart';
import 'game_session.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  late ConfettiController _confettiController;
  late GameSession gameSession;
  late bool liarCaught;
  late String winnerText;
  late Color winnerColor;
  List<String> mostVotedPlayers = [];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    gameSession = ModalRoute.of(context)!.settings.arguments as GameSession;
    _calculateResults();
  }

  void _calculateResults() {
    int maxVotes = 0;
    if (gameSession.votes.isNotEmpty) {
      gameSession.votes.forEach((player, votes) {
        if (votes > maxVotes) {
          maxVotes = votes;
          mostVotedPlayers = [player];
        } else if (votes == maxVotes) {
          mostVotedPlayers.add(player);
        }
      });
    }

    final bool tie = mostVotedPlayers.length > 1;
    liarCaught =
        mostVotedPlayers.length == 1 &&
        mostVotedPlayers.first == gameSession.liar;

    if (tie) {
      winnerText = '라이어 승리! (동점)';
      winnerColor = AppColors.primary;
    } else if (liarCaught) {
      winnerText = '시민 승리!';
      winnerColor = AppColors.accent;
      // build가 완료된 후 confetti를 실행해야 안전합니다.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _confettiController.play();
      });
    } else {
      winnerText = '라이어 승리!';
      winnerColor = AppColors.primary;
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _restartGame() {
    final newSession = GameSession(players: gameSession.players);
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
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: liarCaught
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
                        winnerText,
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
                      ElevatedButton(
                        onPressed: _restartGame,
                        child: const Text('같은 멤버로 다시하기'),
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
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple,
            ],
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
                  gameSession.liar,
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
                  gameSession.word,
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
    if (gameSession.votes.isEmpty) {
      return const Center(child: Text('투표가 진행되지 않았습니다.'));
    }

    final barGroups = <BarChartGroupData>[];
    int i = 0;
    for (var player in gameSession.players) {
      final voteCount = gameSession.votes[player] ?? 0;
      barGroups.add(
        BarChartGroupData(
          x: i++,
          barRods: [
            BarChartRodData(
              toY: voteCount.toDouble(),
              color: Theme.of(context).primaryColor,
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
                getTitlesWidget: (value, meta) => Text(
                  gameSession.players[value.toInt()],
                  style: textTheme.bodySmall,
                ),
                reservedSize: 30,
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
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
