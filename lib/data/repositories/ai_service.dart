import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  static const String apiKey = "AIzaSyApqhdLF8wa3gKufi56lcljgH5pmTs1PvY";
  static const String apiUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey";

  Future<List<String>> generateWords() async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": "Generate 6 random common words."}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.containsKey("candidates")) {
          final text = data["candidates"][0]["content"]["parts"][0]["text"];
          return text.split(" "); // Convert the response into a list of words
        } else {
          throw Exception("Invalid response format: $data");
        }
      } else {
        throw Exception("API Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Gemini API Error: $e");
      throw Exception("Failed to fetch words");
    }
  }
}