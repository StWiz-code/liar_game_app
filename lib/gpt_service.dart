import 'dart:convert';
import 'package:http/http.dart' as http;
import 'game_session.dart';
import 'secrets.dart';

class GptService {
  final String _apiUrl = 'https://api.openai.com/v1/chat/completions';

  // --- 수정된 라이어 추리 함수 ---
  Future<String> getLiarHint(GameSession gameSession) async {
    final descriptionsText = gameSession.descriptions.entries
        .map((entry) => '- ${entry.key}: "${entry.value}"')
        .join('\n');

    // 프롬프트를 더 간결하게 수정
    final prompt =
        '''
당신은 라이어 게임 분석가입니다. 아래 정보를 보고 라이어일 확률이 가장 높은 사람 한 명과 그 핵심 이유를 간결하게 분석해주세요.

### 게임 정보
- 주제: ${gameSession.topic}
- 참여자 및 설명:
$descriptionsText

### 임무
1. 가장 라이어 같은 사람 한 명을 지목하세요.
2. 그 이유를 한두 문장으로 요약해서 설명해주세요.
3. 답변은 매우 간결하게, 핵심만 추려서 한국어로만 제공해주세요.
4. 절대 제시어를 직접 언급하지 마세요.
''';

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAiApiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini', // 추천 모델로 변경
          'messages': [
            {
              'role': 'system',
              'content': 'You are a concise analyst for the Liar Game.',
            },
            {'role': 'user', 'content': prompt},
          ],
          'max_tokens': 150, // 답변 길이를 제한하여 토큰 사용량 절약
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        return body['choices'][0]['message']['content'];
      } else {
        final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
        return 'API 오류가 발생했습니다: ${errorBody['error']['message']}';
      }
    } catch (e) {
      return '힌트를 가져오는 중 오류가 발생했습니다: $e';
    }
  }

  // 제시어 설명 힌트 함수 (변경 없음)
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

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAiApiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini', // 추천 모델로 변경
          'messages': [
            {
              'role': 'system',
              'content': 'You are a helpful assistant for the Liar Game.',
            },
            {'role': 'user', 'content': prompt},
          ],
          'max_tokens': 150,
          'temperature': 0.5,
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        return body['choices'][0]['message']['content'];
      } else {
        final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
        return 'API 오류: ${errorBody['error']['message']}';
      }
    } catch (e) {
      return '힌트 생성 중 오류 발생: $e';
    }
  }
}
