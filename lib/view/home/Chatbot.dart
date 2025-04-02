import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void showChatbot(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return ChatbotPopup();
    },
  );
}

class ChatbotPopup extends StatefulWidget {
  @override
  _ChatbotPopupState createState() => _ChatbotPopupState();
}

class _ChatbotPopupState extends State<ChatbotPopup> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final String geminiApiKey = "AIzaSyCujKp6IMWUmJx6qYTnSV9zK8aGTIl4_0g"; // Replace with your Gemini API key

  Future<String> fetchAIResponse(String userMessage) async {
    // Remove the `const` keyword here
    final String apiUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$geminiApiKey";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": "You are a chatbot that only answers questions about Multiple Sclerosis (MS) ou sclerose en plaques en francais (SEP)."},
                {"text": userMessage}
              ]
            }
          ]
        }),
      );

      print("Response Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return data["candidates"][0]["content"]["parts"][0]["text"];
      } else {
        return "Error: Unable to fetch response. Status code: ${response.statusCode}";
      }
    } catch (e) {
      return "Error: $e";
    }
  }

  void _sendMessage() async {
    String userMessage = _controller.text.trim();
    if (userMessage.isNotEmpty) {
      setState(() {
        _messages.add({"user": userMessage});
      });

      // Check if the message is related to Multiple Sclerosis
      bool isMSRelated = userMessage.toLowerCase().contains("multiple sclerosis") ||
          userMessage.toLowerCase().contains("ms") ||
          userMessage.toLowerCase().contains("sep") ||
          userMessage.toLowerCase().contains("sclérose en plaques");

      if (isMSRelated) {
        String botResponse = await fetchAIResponse(userMessage);
        setState(() {
          _messages.add({"bot": botResponse});
        });
      } else {
        setState(() {
          _messages.add({"bot": "Sorry, I can only answer questions about Multiple Sclerosis (MS)."});
        });
      }

      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Assistant SEP",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              IconButton(
                icon: Icon(Icons.close, size: 30, color: Colors.blue),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                String key = _messages[index].keys.first;
                return Align(
                  alignment: key == "user" ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                    decoration: BoxDecoration(
                      color: key == "user" ? Colors.blueAccent : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _messages[index][key]!,
                      style: TextStyle(
                          color: key == "user" ? Colors.white : Colors.black,
                          fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: "Ask me about Multiple Sclerosis...",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send, color: Colors.blue, size: 30),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
