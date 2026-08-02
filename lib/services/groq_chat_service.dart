import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class GroqChatService {
  final List<Map<String, String>> _messages = [
    {
      "role": "system",
      "content": AppConstants.systemPrompt,
    }
  ];

  Future<String> sendMessage(String message) async {
    _messages.add({
      "role": "user",
      "content": message,
    });

    final response = await http.post(
      Uri.parse(
        "https://api.groq.com/openai/v1/chat/completions",
      ),
      headers: {
        "Authorization":
            "Bearer ${AppConstants.groqApiKey}",
        "Content-Type":
            "application/json",
      },
      body: jsonEncode({
        "model": AppConstants.model,
        "messages": _messages,
        "temperature": 0.7,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }

    final json = jsonDecode(response.body);

    final reply =
        json["choices"][0]["message"]["content"];

    _messages.add({
      "role": "assistant",
      "content": reply,
    });

    return reply;
  }

  void clearConversation() {
    _messages
      ..clear()
      ..add({
        "role": "system",
        "content": AppConstants.systemPrompt,
      });
  }
}