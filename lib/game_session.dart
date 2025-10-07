import 'dart:math';

class GameSession {
  final List<String> players;
  final String liar;
  final String topic;
  final String word; // 시민의 단어
  final String liarWord; // 라이어의 단어
  int currentPlayerIndex;
  final Map<String, String> descriptions;
  final Map<String, int> votes;

  // factory 생성자 패턴을 사용하여 복잡한 초기화 로직을 처리합니다.
  factory GameSession({required List<String> players}) {
    // 1. 주제와 시민의 단어를 먼저 결정합니다.
    final topic = _wordList.keys.elementAt(Random().nextInt(_wordList.length));
    final word = _getWordForTopic(topic);

    // 2. 시민의 단어를 제외한 나머지 단어 리스트를 만듭니다.
    final otherWords = _wordList[topic]!.where((w) => w != word).toList();

    // 3. 나머지 단어 중에서 라이어의 단어를 무작위로 선택합니다.
    final liarWord = otherWords[Random().nextInt(otherWords.length)];

    // 4. 라이어를 결정합니다.
    final liar = players[Random().nextInt(players.length)];

    // 5. 결정된 값들로 내부 생성자를 호출하여 객체를 생성합니다.
    return GameSession._internal(
      players: players,
      liar: liar,
      topic: topic,
      word: word,
      liarWord: liarWord, // 새로 뽑은 라이어의 단어를 전달합니다.
    );
  }

  // 실제 객체 생성을 담당하는 private 생성자입니다.
  GameSession._internal({
    required this.players,
    required this.liar,
    required this.topic,
    required this.word,
    required this.liarWord, // 라이어의 단어를 받도록 수정합니다.
  }) : currentPlayerIndex = 0,
       descriptions = {},
       votes = {};

  // 주제에 맞는 단어를 가져오는 static 함수는 그대로 사용합니다.
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
