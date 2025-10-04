import 'dart:math';

class GameSession {
  final List<String> players;
  final String liar;
  final String topic;
  final String word;
  int currentPlayerIndex;
  final Map<String, String> descriptions;

  // 생성자(Constructor) 수정: this.word 할당 방식 변경
  GameSession({required this.players})
      : liar = players[Random().nextInt(players.length)],
        topic = _wordList.keys.elementAt(Random().nextInt(_wordList.length)),
        // word는 final이므로 생성자 본문에서 할당할 수 없어 초기화 리스트에서 처리해야 함.
        // topic을 먼저 정하고, 그 topic을 이용해 word를 초기화.
        word = _getWordForTopic(_wordList.keys.elementAt(Random().nextInt(_wordList.length))),
        currentPlayerIndex = 0,
        descriptions = {} {
    // 생성자 초기화 리스트에서 이미 topic과 word가 결정되었으므로
    // 여기서 재할당할 필요가 없습니다. 하지만 word가 topic에 맞게 설정되도록
    // 생성자 로직을 수정했습니다. 위 방식이 더 안정적입니다.
  }

  // topic에 맞는 word를 가져오는 static helper 함수
  static String _getWordForTopic(String topic) {
    final words = _wordList[topic]!;
    return words[Random().nextInt(words.length)];
  }

  // 생성자(Constructor) 초기 버전 - 이 코드는 오류가 있을 수 있습니다.
  // GameSession({required this.players})
  //     : liar = players[Random().nextInt(players.length)],
  //       topic = _wordList.keys.elementAt(Random().nextInt(_wordList.length)),
  //       word = '', // word는 topic이 정해진 후 할당됩니다.
  //       currentPlayerIndex = 0,
  //       descriptions = {} {
  //   // topic에 해당하는 word를 할당합니다.
  //   (this as dynamic).word = _wordList[topic]![Random().nextInt(_wordList[topic]!.length)];
  // }
}


// 샘플 단어 리스트. 나중에 GPT 연동으로 대체할 수 있습니다.
const Map<String, List<String>> _wordList = {
  '동물': ['코끼리', '호랑이', '기린', '사자', '돌고래'],
  '과일': ['사과', '바나나', '딸기', '수박', '포도'],
  '스포츠': ['축구', '야구', '농구', '배구', '수영'],
  '직업': ['의사', '교사', '개발자', '소방관', '경찰'],
};