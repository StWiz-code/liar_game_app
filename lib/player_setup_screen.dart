import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'game_session.dart';

class PlayerSetupScreen extends StatefulWidget {
  const PlayerSetupScreen({super.key});

  @override
  State<PlayerSetupScreen> createState() => _PlayerSetupScreenState();
}

class _PlayerSetupScreenState extends State<PlayerSetupScreen> {
  final List<String> _players = [];
  final TextEditingController _controller = TextEditingController();
  String? _errorMessage;

  void _addPlayer() {
    final playerName = _controller.text.trim();
    if (playerName.isNotEmpty && !_players.contains(playerName)) {
      if (_players.length >= 8) {
        setState(() {
          _errorMessage = '최대 8명까지 참여할 수 있습니다.';
        });
        return;
      }
      setState(() {
        _players.add(playerName);
        _controller.clear();
        _errorMessage = null;
      });
    } else {
      setState(() {
        _errorMessage = '유효하지 않거나 중복된 이름입니다.';
      });
    }
  }

  void _removePlayer(String player) {
    setState(() {
      _players.remove(player);
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
    Navigator.pushNamed(context, '/role_check', arguments: gameSession);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('참가자 설정')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '참가할 플레이어의 이름을\n입력해주세요 (3~8명)',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: '이름 입력...',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _addPlayer(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 120,
                    child: GradientButton(
                      onPressed: _addPlayer,
                      text: '추가',
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.accentPink,
                          AppColors.accentLightPink,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 20),
              Expanded(
                child: Card(
                  child: _players.isEmpty
                      ? Center(
                          child: Text(
                            '아직 참가자가 없습니다.',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: _players.length,
                          itemBuilder: (context, index) {
                            final player = _players[index];
                            return ListTile(
                              leading: CircleAvatar(
                                // ## 이 부분이 수정되었습니다 ##
                                // child 인자를 마지막으로 이동
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                child: Text('${index + 1}'),
                              ),
                              title: Text(
                                player,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.grey,
                                ),
                                onPressed: () => _removePlayer(player),
                              ),
                            );
                          },
                        ),
                ),
              ),
              const SizedBox(height: 20),
              GradientButton(
                onPressed: _players.length >= 3 ? _startGame : null,
                text: '게임 시작 (${_players.length}명)',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
