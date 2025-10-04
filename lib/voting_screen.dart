import 'package:flutter/material.dart';
import 'game_session.dart';

class VotingScreen extends StatefulWidget {
  VotingScreen({super.key});

  @override
  State<VotingScreen> createState() => _VotingScreenState();
}

class _VotingScreenState extends State<VotingScreen> {
  GameSession? gameSession;
  int currentVoterIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (gameSession == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is GameSession) {
        setState(() {
          gameSession = args;
        });
      }
    }
  }

  void _castVote(String votedFor) {
    setState(() {
      gameSession!.votes.update(votedFor, (value) => value + 1, ifAbsent: () => 1);

      if (currentVoterIndex < gameSession!.players.length - 1) {
        currentVoterIndex++;
      } else {
        Navigator.pushReplacementNamed(context, '/results', arguments: gameSession);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (gameSession == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentVoter = gameSession!.players[currentVoterIndex];

    return Scaffold(
      appBar: AppBar(title: Text('${currentVoter}님의 투표')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('라이어라고 생각하는 사람을 선택하세요.', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: gameSession!.descriptions.entries.map((entry) {
                  return Card(
                    child: ListTile(
                      title: Text(entry.key),
                      subtitle: Text(entry.value),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              alignment: WrapAlignment.center,
              children: gameSession!.players.map((player) {
                final isSelf = player == currentVoter;
                return ElevatedButton(
                  onPressed: isSelf ? null : () => _castVote(player),
                  child: Text(player),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}