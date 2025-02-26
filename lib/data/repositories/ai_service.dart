import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AIService {
  static const String apiKey = "AIzaSyBZQe1llW9DUioerUA4SE6NzzGbP97t30o";
  static const String apiUrl =
      "https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent?key=$apiKey";

  // Fetch activities with caching logic
// Fetch activities from AI API
Future<List<Map<String, String>>> getActivities() async {
  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {
                "text": "Suggest 4 activities for multiple sclerosis (sclerose en plaque) patients. "
                        "Return as a JSON array with string values: [{\"activity\": \"string\", \"description\": \"string\"}]"
              }
            ]
          }
        ]
      }),
    );

    print("Raw Response: ${response.body}"); // Debugging

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data["candidates"] == null || data["candidates"].isEmpty) {
        throw Exception("No valid response from AI.");
      }

      // Extract AI response text
      String textResponse = data["candidates"][0]["content"]["parts"][0]["text"];
      print("AI Raw Output: $textResponse");

      // Remove markdown-style code block if present
      textResponse = textResponse.trim();
      if (textResponse.startsWith("```json")) {
        textResponse = textResponse.replaceAll("```json", "").replaceAll("```", "").trim();
      }

      // Ensure response is a valid JSON array
      if (!textResponse.startsWith("[")) {
        throw Exception("Unexpected AI response format. Expected JSON array.");
      }

      // Decode JSON safely
      final List<dynamic> parsedList = jsonDecode(textResponse);
      List<Map<String, String>> safeList = parsedList.map((item) {
        return {
          "activity": item["activity"].toString(),  // Convert values to String
          "description": item["description"].toString(),
        };
      }).toList();

      return safeList;
    } else {
      throw Exception("Failed to fetch AI-generated activities: ${response.statusCode}");
    }
  } catch (e) {
    print("Error: $e");
    return [];
  }
}

}