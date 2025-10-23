import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'game_session.dart';
import 'secrets.dart';

class GptService {
  final String _apiUrl = 'https://api.openai.com/v1/chat/completions';

  /// 플레이어가 자기 단어를 어떻게 설명할지 팁을 주는 힌트
  Future<String> getWordHint({
    required String topic,
    required String word,
    required bool isLiar,
  }) async {
    final role = isLiar ? "라이어" : "시민";
    final prompt =
        '''
      당신은 라이어 게임 전문가입니다. 플레이어에게 제시어 설명에 대한 힌트를 간결하게 제공해주세요.

      - 역할: $role
      - 주제: $topic
      - 받은 단어: $word

      임무:
      1. 받은 단어 '$word'에 대해 한 문장으로 간단히 설명해주세요.
      2. 이 단어를 어떻게 설명하면 좋을지 구체적인 팁 한 가지를 제안해주세요.
         - $role 입장에서 의심받지 않을 만한 좋은 설명 방법을 알려주세요.
      3. 답변은 매우 간결하게, 두세 문장으로 요약해서 한국어로만 제공해주세요.
    ''';
    return _callGptApi(prompt, maxTokens: 150);
  }

  /// AI 플레이어가 스스로 제시어를 설명하는 문장을 생성 (프롬프트 강화 버전)
  Future<String> generateAIDescription({
    required String playerName,
    required String topic,
    required String word,
    required bool isLiar,
    required List<String> previousDescriptions,
  }) async {
    final role = isLiar ? "라이어" : "시민";
    final previousDescriptionsText = previousDescriptions.isEmpty
        ? "아직 아무도 설명하지 않았습니다."
        : previousDescriptions.map((d) => '- "$d"').join('\n');

    final prompt =
        '''
      당신은 '$playerName'이라는 이름의 매우 숙련된 라이어 게임 플레이어입니다. 당신의 역할은 '$role'입니다.
      - 주제: $topic
      - 당신이 받은 단어: $word
      - 다른 참가자들의 이전 설명:
      $previousDescriptionsText

      ### 절대 규칙 (반드시 지켜야 함) ###
      1.  **절대 단어의 핵심 특징이나 기능을 직접적으로 설명하지 마세요.**
      2.  **설명은 8단어 이내로 매우 짧아야 합니다.**
      3.  **다른 사람의 설명과 절대 겹치지 않게 설명하세요.**
      4.  매우 간접적이고, 애매모호하고, 창의적으로 설명해야 합니다.

      ### 역할별 전략 (매우 중요) ###
      - **라이어일 경우:** 당신의 단어 '$word'에 대한 설명이면서, 동시에 주제 '$topic'과도 어떻게든 연관성이 있어 보이도록 교묘하게 설명하여 시민인 척 하세요.
      - **시민일 경우:** 다른 사람도 쉽게 할 수 있는 가장 뻔한 설명은 피하고, 약간의 개성을 담아 설명하여 라이어가 아님을 어필하세요.

      ### 설명 방식 예시 ###
      - 단어가 '축구'일 경우:
        - 나쁜 설명 (너무 직접적): "발로 공을 차는 스포츠입니다."
        - 좋은 설명 (간접적): "22명이 잔디밭에서 뛰어다닙니다."
      - 단어가 '스마트폰'일 경우:
        - 나쁜 설명 (너무 직접적): "매일 들고 다니는 작은 컴퓨터입니다."
        - 좋은 설명 (간접적): "이게 없으면 불안해하는 사람들이 많습니다."

      ### 임무 ###
      위의 '절대 규칙', '역할별 전략', '설명 방식 예시'를 완벽히 숙지하여, 당신의 역할에 맞는 설명을 딱 한 문장으로 만드세요.
      답변은 오직 당신의 '설명' 한 문장만, 다른 어떤 부연 설명이나 따옴표 없이 한국어로 말해주세요.
    ''';
    return _callGptApi(prompt, maxTokens: 40, temperature: 0.9);
  }

  /// AI 플레이어가 다른 플레이어들의 설명을 듣고 라이어에게 투표 (프롬프트 강화 버전)
  Future<String> castAIVote(GameSession gameSession, String myName) async {
    final descriptionsText = gameSession.descriptions.entries
        .map((entry) => '- ${entry.key}: "${entry.value}"')
        .join('\n');

    final voteTargets = gameSession.players.where((p) => p != myName).toList();

    final prompt =
        '''
      당신은 '$myName'이라는 이름의 매우 논리적인 라이어 게임 분석가입니다. 모든 참가자의 설명이 끝났습니다. 라이어를 찾아내야 합니다.
      - 주제: ${gameSession.topic}
      - 모든 참가자의 설명:
      $descriptionsText
      - 투표 가능 대상: ${voteTargets.join(', ')}

      ### 분석 가이드라인 ###
      1. 주제 '${gameSession.topic}'과 가장 동떨어지거나 어색한 설명을 한 사람을 찾으세요.
      2. 너무 광범위하거나 애매해서 정체를 숨기려는 의도가 보이는 사람을 찾으세요.
      3. 다른 사람의 설명과 미묘하게 맥락이 다른 설명을 한 사람을 찾으세요.

      ### 임무 ###
      위의 '분석 가이드라인'에 따라 설명들을 면밀히 검토하고, 라이어일 확률이 가장 높은 사람 한 명을 지목하세요.
      답변은 오직 당신이 투표할 사람의 '이름'만 정확하게 말해주세요. 다른 어떤 설명도 추가하지 마세요.
    ''';

    try {
      final votedPlayer = await _callGptApi(prompt, maxTokens: 10);
      if (voteTargets.contains(votedPlayer.trim())) {
        return votedPlayer.trim();
      } else {
        return voteTargets[Random().nextInt(voteTargets.length)];
      }
    } catch (e) {
      return voteTargets[Random().nextInt(voteTargets.length)];
    }
  }

  /// GPT API를 호출하는 공통 비공개 함수
  Future<String> _callGptApi(
    String prompt, {
    int maxTokens = 150,
    double temperature = 0.7,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAiApiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
          'max_tokens': maxTokens,
          'temperature': temperature,
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        return body['choices'][0]['message']['content'].trim();
      } else {
        return 'API 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
      }
    } catch (e) {
      return '오류가 발생했습니다: $e';
    }
  }
}
