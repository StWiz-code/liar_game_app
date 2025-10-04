import 'package:flutter/material.dart';
import 'game_session.dart';

class ResultsScreen extends StatelessWidget {
  ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameSession = ModalRoute.of(context)!.settings.arguments as GameSession;

    String mostVotedPlayer = '';
    int maxVotes = 0;
    if (gameSession.votes.isNotEmpty) {
      gameSession.votes.forEach((player, votes) {
        if (votes > maxVotes) {
          maxVotes = votes;
          mostVotedPlayer = player;
        }
      });
    } else {
      mostVotedPlayer = '아무도 투표하지 않았습니다';
    }


    final bool liarCaught = mostVotedPlayer == gameSession.liar;
    final String winnerText = liarCaught ? '시민 승리!' : '라이어 승리!';
    final Color winnerColor = liarCaught ? Colors.blue : Colors.red;

    return Scaffold(
      appBar: AppBar(title: const Text('게임 결과')),
      body: Center(
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
              ),
              const SizedBox(height: 30),
              Text('라이어는 ${gameSession.liar}였습니다.', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 10),
              Text('제시어: ${gameSession.word}', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 40),
              const Text('투표 결과', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              if (gameSession.votes.isEmpty)
                const Text('투표가 진행되지 않았습니다.', style: TextStyle(fontSize: 16))
              else
                ...gameSession.votes.entries.map((entry) {
                  return Text('${entry.key}: ${entry.value}표', style: const TextStyle(fontSize: 16));
                }).toList(),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  final newSession = GameSession(players: gameSession.players);
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
                  Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                },
                child: const Text('처음으로'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}