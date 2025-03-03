import 'package:flutter/material.dart';

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

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _messages.add({"user": _controller.text});
        _messages.add(
            {"bot": "Hello! How can I assist you with Multiple Sclerosis?"});
      });
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      height: MediaQuery.of(context).size.height * 0.75, // Increased height for better usage
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
                "Chatbot",
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
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
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        )
                      ],
                    ),
                    child: Text(
                      _messages[index][key]!,
                      style: TextStyle(
                          color: key == "user" ? Colors.white : Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
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
                  maxLines: 3, // Allow multiline text input
                  decoration: InputDecoration(
                    hintText: "Ask me anything about Multiple Sclerosis...",
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.blueAccent),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    filled: true,
                    fillColor: Colors.grey[100],
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