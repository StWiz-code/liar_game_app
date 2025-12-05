import 'dart:math';

// [추가됨] 난이도 구분을 위한 열거형
enum GameDifficulty {
  easy, // 쉬움: AI가 다소 직접적으로 설명 (초보자용)
  normal, // 보통: 현재 수준
  hard, // 어려움: 매우 추상적이고 비유적인 설명 (고수용)
}

class GameSession {
  final List<String> players;
  final String liar;
  final String topic;
  final String word;
  final String liarWord;
  int currentPlayerIndex;
  final Map<String, String> descriptions;
  final Map<String, int> votes;

  // [추가됨] 게임의 난이도 저장
  final GameDifficulty difficulty;

  factory GameSession({
    required List<String> players,
    GameDifficulty difficulty = GameDifficulty.normal, // 기본값 보통
  }) {
    final topic = _wordList.keys.elementAt(Random().nextInt(_wordList.length));
    final word = _getWordForTopic(topic);
    final otherWords = _wordList[topic]!.where((w) => w != word).toList();
    final liarWord = otherWords[Random().nextInt(otherWords.length)];
    final liar = players[Random().nextInt(players.length)];

    return GameSession._internal(
      players: players,
      liar: liar,
      topic: topic,
      word: word,
      liarWord: liarWord,
      difficulty: difficulty, // [추가됨]
    );
  }

  GameSession._internal({
    required this.players,
    required this.liar,
    required this.topic,
    required this.word,
    required this.liarWord,
    required this.difficulty, // [추가됨]
  })  : currentPlayerIndex = 0,
        descriptions = {},
        votes = {};

  static String _getWordForTopic(String topic) {
    final words = _wordList[topic]!;
    return words[Random().nextInt(words.length)];
  }
}

// ## 이 부분이 수정되었습니다! ##
// 기존 주제에 5가지 새로운 주제를 추가하여 총 9개의 주제가 있습니다.
const Map<String, List<String>> _wordList = {
  // --- 기존 주제 ---
  '동물': ['코끼리', '호랑이', '기린', '사자', '돌고래'],
  '과일': ['사과', '바나나', '딸기', '수박', '포도'],
  '스포츠': ['축구', '야구', '농구', '배구', '수영'],
  '직업': ['의사', '교사', '개발자', '소방관', '경찰'],
  // --- 새로 추가된 주제 ---
  '음료': ['콜라', '사이다', '아메리카노', '주스', '우유'],
  '나라': ['대한민국', '미국', '일본', '중국', '프랑스'],
  '전자기기': ['스마트폰', '노트북', '텔레비전', '에어컨', '냉장고'],
  '영화 장르': ['액션', '코미디', '로맨스', '공포', 'SF'],
  'K-POP 그룹': ['BTS', '블랙핑크', '뉴진스', '세븐틴', '아이브'],
};
