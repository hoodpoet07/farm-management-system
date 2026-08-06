import 'dart:convert';
import 'package:farm_management_system/utils/constants.dart';
import 'package:http/http.dart' as http;
import '../database/database_helper.dart';
import 'package:flutter/foundation.dart';

class ChatService {
  final String _apiKey = AppConstants.groqApiKey;

  Future<String> sendMessage(String userMessage) async {
    try{
      debugPrint("Sending message to AI: $userMessage");

    final summary = await DatabaseHelper.instance.getSystemSummaryContext();

    // 2. Build AI System Context
    final systemPrompt = '''
You are RIMAI, an intelligent farm management assistant.

You help farmers with:

• Poultry management
• Chicken diseases
• Vaccination schedules
• Feed management
• Mortality analysis
• Expenses
• Sales
• Purchases
• Profit calculations
• Farm record keeping


Current Live Farm Data:
- Active Birds: ${summary['activeBirds']}
- Total Sales Revenue: \$${summary['totalSales']}
- Total Expenses: \$${summary['totalExpenses']}
- Feed Inventory Cost: \$${summary['totalFeedCost']}
- Total Mortality Recorded: ${summary['totalMortality']}

If the user asks to add an expense or chicken batch, respond ONLY with a JSON payload in this format:
{"action": "ADD_EXPENSE", "title": "...", "amount": 0.0, "category": "..."}
{"action": "ADD_BATCH", "batchName": "...", "breed": "...", "quantity": 0, "costPerBird": 0.0}

Otherwise, answer their query standardly using the live farm data above.If the question is unrelated to farming, tell them what you are for.
''';

    // 3. Make HTTP call to AI Model Endpoint (Groq / OpenAI compatible format)
    final response = await http.post(
      Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        "model": AppConstants.model,
        "messages": [
          {"role": "system", "content": systemPrompt},
          {"role": "user", "content": userMessage}
        ],
        "temperature": 0.2
      }),
    );

    debugPrint("API Response Status: ${response.statusCode}");
    debugPrint("API Response: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      return "Sorry, I had trouble reaching the AI service.";
    }
  }catch(e,stack){
    debugPrint("Exception in ChatService: $e");
    debugPrint("Stacktrace: $stack");
    return "Network error: Unable to communicate with AI server. Details: $e";
  }
  }
}
