import 'package:flutter/material.dart';
import 'game_session.dart';

class PlayerSetupScreen extends StatefulWidget {
  const PlayerSetupScreen({super.key}); // 'const' 추가

  @override
  // 반환 타입 '_PlayerSetupScreenState' 제거
  createState() => _PlayerSetupScreenState();
}

class _PlayerSetupScreenState extends State<PlayerSetupScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _players = [];
  String _errorMessage = '';

  void _addPlayer() {
    final playerName = _controller.text.trim();
    if (playerName.isEmpty) {
      setState(() {
        _errorMessage = '이름을 입력해주세요!';
      });
      return;
    }
    if (_players.contains(playerName)) {
      setState(() {
        _errorMessage = '이미 존재하는 이름입니다!';
      });
      return;
    }
    setState(() {
      _players.add(playerName);
      _controller.clear();
      _errorMessage = '';
    });
  }

  void _startGame() {
    if (_players.length < 3) {
      setState(() {
        _errorMessage = '최소 3명의 플레이어가 필요합니다!';
      });
      return;
    }

    final gameSession = GameSession(players: _players);
    print('✅ RoleCheckScreen으로 데이터 전달 시도: $gameSession');
    Navigator.pushNamed(context, '/role_check', arguments: gameSession);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('플레이어 설정')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: '플레이어 이름',
                  border: const OutlineInputBorder(),
                  errorText: _errorMessage.isEmpty ? null : _errorMessage,
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _addPlayer(),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _addPlayer,
                child: const Text('플레이어 추가'),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _players.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_players[index]),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            _players.removeAt(index);
                            _errorMessage = '';
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(onPressed: _startGame, child: const Text('게임 시작')),
            ],
          ),
        ),
      ),
    );
  }
}
