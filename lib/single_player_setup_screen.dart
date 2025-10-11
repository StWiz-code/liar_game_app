import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'game_session.dart';

class SinglePlayerSetupScreen extends StatefulWidget {
  const SinglePlayerSetupScreen({super.key});

  @override
  State<SinglePlayerSetupScreen> createState() =>
      _SinglePlayerSetupScreenState();
}

class _SinglePlayerSetupScreenState extends State<SinglePlayerSetupScreen> {
  final List<TextEditingController> _controllers = [TextEditingController()];
  String? _errorMessage;

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addPlayerField() {
    if (_controllers.length < 2) {
      setState(() {
        _controllers.add(TextEditingController());
      });
    }
  }

  void _removePlayerField(int index) {
    if (_controllers.length > 1) {
      setState(() {
        // 컨트롤러를 먼저 dispose하고 리스트에서 제거합니다.
        _controllers[index].dispose();
        _controllers.removeAt(index);
      });
    }
  }

  void _startGame() {
    final playerNames = _controllers.map((c) => c.text.trim()).toList();

    if (playerNames.any((name) => name.isEmpty)) {
      setState(() {
        _errorMessage = '모든 플레이어의 이름을 입력해주세요!';
      });
      return;
    }
    // 중복된 이름 확인
    if (playerNames.toSet().length != playerNames.length) {
      setState(() {
        _errorMessage = '중복된 이름이 있습니다!';
      });
      return;
    }

    // 플레이어 수에 따라 AI 수 결정 (1명일 때 2명, 2명일 때 1명)
    final int aiCount = (_controllers.length == 1) ? 2 : 1;
    final aiPlayers = List.generate(aiCount, (index) => 'AI ${index + 1}');

    final allPlayers = [...playerNames, ...aiPlayers]..shuffle();

    final gameSession = GameSession(players: allPlayers);
    Navigator.pushNamed(context, '/role_check', arguments: gameSession);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('혼자/둘이 하기 설정')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '플레이어의 이름을 입력해주세요.\n(1~2명)',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 32),

              // 동적으로 플레이어 입력 필드 생성
              ..._buildPlayerFields(),

              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              const Spacer(),
              GradientButton(onPressed: _startGame, text: '게임 시작'),
            ],
          ),
        ),
      ),
    );
  }

  /// 플레이어 입력 필드를 동적으로 생성하는 헬퍼 함수
  List<Widget> _buildPlayerFields() {
    List<Widget> fields = [];
    for (int i = 0; i < _controllers.length; i++) {
      fields.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controllers[i],
                  decoration: InputDecoration(
                    labelText: '플레이어 ${i + 1} 이름',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                  ),
                ),
              ),
              // 두 번째 플레이어 필드에만 삭제 버튼 표시
              if (i == 1)
                IconButton(
                  icon: const Icon(
                    Icons.remove_circle_outline,
                    color: AppColors.accentPink,
                  ),
                  onPressed: () => _removePlayerField(i),
                ),
            ],
          ),
        ),
      );
    }

    // 플레이어가 1명일 때만 '플레이어 2 추가' 버튼 표시
    if (_controllers.length < 2) {
      fields.add(
        OutlinedButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('플레이어 2 추가'),
          onPressed: _addPlayerField,
        ),
      );
    }
    return fields;
  }
}
