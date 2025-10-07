import 'package:flutter/material.dart';
import 'game_session.dart';

class ResultsScreen extends StatelessWidget {
  ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameSession =
        ModalRoute.of(context)!.settings.arguments as GameSession;

    // 동점자 처리를 위해 mostVotedPlayers를 List로 변경
    List<String> mostVotedPlayers = [];
    int maxVotes = 0;

    if (gameSession.votes.isNotEmpty) {
      gameSession.votes.forEach((player, votes) {
        if (votes > maxVotes) {
          maxVotes = votes;
          mostVotedPlayers = [player]; // 새로운 최대 득표자
        } else if (votes == maxVotes) {
          mostVotedPlayers.add(player); // 동점자 추가
        }
      });
    }

    // 승리 조건 판정 로직 수정
    final bool liarCaught =
        mostVotedPlayers.length == 1 &&
        mostVotedPlayers.first == gameSession.liar;
    final bool tie = mostVotedPlayers.length > 1;

    final String winnerText;
    final Color winnerColor;

    if (tie) {
      winnerText = '라이어 승리! (동점)';
      winnerColor = Colors.red;
    } else if (liarCaught) {
      winnerText = '시민 승리!';
      winnerColor = Colors.blue;
    } else {
      winnerText = '라이어 승리!';
      winnerColor = Colors.red;
    }

    // 최다 득표자 표시 텍스트
    final String mostVotedText;
    if (mostVotedPlayers.isEmpty) {
      mostVotedText = '최다 득표자: 없음';
    } else {
      mostVotedText = '최다 득표자: ${mostVotedPlayers.join(', ')}';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('게임 결과')),
      // body 부분을 SafeArea 위젯으로 감싸줍니다.
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  winnerText,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: winnerColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Text(
                  '라이어는 ${gameSession.liar}였습니다.',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 10),
                Text(
                  '제시어: ${gameSession.word}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 40),

                // 최다 득표자 정보 추가
                Text(
                  mostVotedText,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  '전체 투표 결과',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (gameSession.votes.isEmpty)
                  const Text('투표가 진행되지 않았습니다.', style: TextStyle(fontSize: 16))
                else
                  ...gameSession.votes.entries.map((entry) {
                    return Text(
                      '${entry.key}: ${entry.value}표',
                      style: const TextStyle(fontSize: 16),
                    );
                  }).toList(),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    // 같은 멤버로 다시 시작하는 로직은 그대로 유지합니다.
                    final newSession = GameSession(
                      players: gameSession.players,
                    );
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/role_check',
                      (route) => false,
                      arguments: newSession,
                    );
                  },
                  child: const Text('같은 멤버로 다시하기'),
                ),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/',
                      (route) => false,
                    );
                  },
                  child: const Text('처음으로'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
