import 'dart:math';

class GameSession {
  final List<String> players;
  final String liar;
  final String topic;
  final String word;
  int currentPlayerIndex;
  final Map<String, String> descriptions;
  final Map<String, int> votes;

  // 복잡한 초기화 로직을 처리하기 위해 factory 생성자 패턴을 사용합니다.
  factory GameSession({required List<String> players}) {
    // 1. 주제와 단어를 먼저 결정합니다.
    final topic = _wordList.keys.elementAt(Random().nextInt(_wordList.length));
    final word = _getWordForTopic(topic);
    // 2. 라이어를 결정합니다.
    final liar = players[Random().nextInt(players.length)];

    // 3. 결정된 값들로 내부 생성자를 호출하여 객체를 생성합니다.
    return GameSession._internal(
      players: players,
      liar: liar,
      topic: topic,
      word: word,
    );
  }

  // 실제 객체 생성을 담당하는 private 생성자입니다.
  GameSession._internal({
    required this.players,
    required this.liar,
    required this.topic,
    required this.word,
  })  : currentPlayerIndex = 0,
        descriptions = {},
        votes = {};

  // 주제에 맞는 단어를 가져오는 static 함수는 그대로 사용합니다.
  static String _getWordForTopic(String topic) {
    final words = _wordList[topic]!;
    return words[Random().nextInt(words.length)];
  }
}

// 샘플 단어 리스트는 변경 없습니다.
const Map<String, List<String>> _wordList = {
  '동물': ['코끼리', '호랑이', '기린', '사자', '돌고래'],
  '과일': ['사과', '바나나', '딸기', '수박', '포도'],
  '스포츠': ['축구', '야구', '농구', '배구', '수영'],
  '직업': ['의사', '교사', '개발자', '소방관', '경찰'],
};