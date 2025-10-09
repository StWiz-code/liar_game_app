import 'dart:async'; // Timer를 사용하기 위해 임포트합니다.
import 'package:flutter/material.dart';
import 'game_session.dart';

class VotingScreen extends StatefulWidget {
  const VotingScreen({super.key});

  @override
  State<VotingScreen> createState() => _VotingScreenState();
}

class _VotingScreenState extends State<VotingScreen> {
  GameSession? gameSession;
  int currentVoterIndex = 0;

  // --- 타이머 관련 변수 추가 ---
  Timer? _timer;
  int _secondsLeft = 15; // 15초로 제한 시간 설정

  @override
  void initState() {
    super.initState();
    // 위젯이 생성될 때 한 번만 실행됩니다.
    // didChangeDependencies 이후에 gameSession이 설정되므로 타이머 시작은 그곳으로 이동합니다.
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
        // gameSession이 설정된 직후 타이머를 시작합니다.
        _startTimer();
      }
    }
  }

  @override
  void dispose() {
    // 화면이 사라질 때 타이머를 반드시 취소하여 메모리 누수를 방지합니다.
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _secondsLeft = 15; // 타이머 초기화
    _timer?.cancel(); // 기존 타이머가 있다면 취소
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() {
          _secondsLeft--;
        });
      } else {
        // 시간이 다 되면 자동으로 다음으로 넘어갑니다. (아무도 선택하지 않은 것으로 처리)
        _nextVoter();
      }
    });
  }

  void _castVote(String votedFor) {
    // 투표를 하면 타이머가 멈추고 다음으로 넘어갑니다.
    _timer?.cancel();
    setState(() {
      gameSession!.votes.update(
        votedFor,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
      _nextVoter();
    });
  }

  void _nextVoter() {
    if (currentVoterIndex < gameSession!.players.length - 1) {
      setState(() {
        currentVoterIndex++;
      });
      _startTimer(); // 다음 투표자를 위해 타이머를 다시 시작합니다.
    } else {
      Navigator.pushReplacementNamed(
        context,
        '/results',
        arguments: gameSession,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (gameSession == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentVoter = gameSession!.players[currentVoterIndex];

    return Scaffold(
      appBar: AppBar(title: Text('$currentVoter님의 투표')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // --- 타이머 UI 추가 ---
              Text(
                '남은 시간: $_secondsLeft초',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: _secondsLeft <= 5 ? Colors.red : null,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              // --- 타이머 진행 바 추가 ---
              LinearProgressIndicator(
                value: _secondsLeft / 15.0,
                backgroundColor: Colors.grey.shade300,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
              const SizedBox(height: 20),
              Text(
                '라이어라고 생각하는 사람을 선택하세요.',
                style: Theme.of(context).textTheme.titleLarge,
              ),
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
      ),
    );
  }
}
