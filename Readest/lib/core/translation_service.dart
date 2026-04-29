import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslationService {
  final String? customAiUrl;
  final String? apiKey;

  TranslationService({this.customAiUrl, this.apiKey});

  /// 翻译核心逻辑：优先尝试 AI 翻译，失败则回退至基础 API
  Future<String> translate(String text, String targetLang) async {
    if (text.trim().isEmpty) return "";

    // 如果配置了自定义 AI 嗅探接口，则使用 AI 翻译以获得更高质量
    if (customAiUrl != null && apiKey != null) {
      return await _translateWithAi(text, targetLang);
    }
    
    // 默认回退逻辑 (此处可接入免费翻译 API 镜像)
    return "翻译功能：[AI 配置未就绪] -> $text";
  }

  Future<String> _translateWithAi(String text, String targetLang) async {
    try {
      final response = await http.post(
        Uri.parse("$customAiUrl/v1/chat/completions"),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "model": "gpt-3.5-turbo", // 或用户嗅探出的模型
          "messages": [
            {
              "role": "system",
              "content": "You are a professional translator. Translate the following text to $targetLang. Provide only the translated text."
            },
            {"role": "user", "content": text}
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'].toString().trim();
      }
      return "AI 翻译失败: ${response.statusCode}";
    } catch (e) {
      return "翻译错误: $e";
    }
  }
}