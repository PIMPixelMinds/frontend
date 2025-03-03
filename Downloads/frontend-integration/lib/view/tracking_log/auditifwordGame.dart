import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pim/data/repositories/ai_service.dart';

class AuditifWordGame extends StatefulWidget {
  @override
  State<AuditifWordGame> createState() => _AuditifWordGameState();
}

class _AuditifWordGameState extends State<AuditifWordGame> {
  final FlutterTts _tts = FlutterTts();
  final AIService _geminiAPI = AIService();

  List<String> _gameWords = [];
  String _userInput = "";
  int _score = 0;
  bool _ttsSpeaking = false;
  bool _gameCompleted = false;

  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _configureTTS();
    _fetchAndSpeakWords();
  }

  void _configureTTS() {
    _tts.setCompletionHandler(() {
      setState(() {
        _ttsSpeaking = false;
      });
    });

    _tts.setStartHandler(() {
      setState(() {
        _ttsSpeaking = true;
      });
    });

    _tts.setLanguage("en-US");
  }

  Future<void> _fetchAndSpeakWords() async {
    try {
      _gameWords = await _geminiAPI.generateWords();
      setState(() {});

      for (String word in _gameWords) {
        await _tts.speak(word);
        await Future.delayed(Duration(seconds: 2)); // Ensure TTS finishes
      }

      setState(() {
        _ttsSpeaking = false;
      });
    } catch (e) {
      print("Error fetching words: $e");
    }
  }

  void _checkAnswer() {
    if (_userInput.isEmpty) {
      print("No input detected, please try again.");
      return;
    }

    String normalizedUserInput = _userInput.toLowerCase().trim();
    List<String> userWords = normalizedUserInput.split(RegExp(r'\s+'));

    int correctCount = 0;
    for (String word in _gameWords) {
      if (userWords.contains(word.toLowerCase())) {
        correctCount++;
      }
    }

    setState(() {
      _score = correctCount;
      _gameCompleted = true;
    });

    _showResultDialog(_score);
  }

  void _showResultDialog(int score) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          "Results",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Poppins', color: Colors.white),
        ),
        backgroundColor: Colors.blue.shade700,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "You remembered $score out of ${_gameWords.length} words!",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontFamily: 'Poppins', color: Colors.white),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _textController.clear();
                  _userInput = "";
                  _score = 0;
                  _gameCompleted = false;
                  _fetchAndSpeakWords();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue.shade700,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Play Again", style: TextStyle(fontSize: 18, fontFamily: 'Poppins')),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade700,
      appBar: AppBar(
        title: const Text("Auditif Word Game",style: TextStyle(fontFamily: 'Poppins', fontSize: 22, fontWeight: FontWeight.bold)),

        backgroundColor: Colors.blue.shade700,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade700, Colors.blue.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Listen to the words, then type them below!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins', color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                _gameWords.isNotEmpty ? "AI Words: ${_gameWords.join(", ")}" : "Loading words...",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins', color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _textController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  labelText: "Type the words you heard",
                  labelStyle: const TextStyle(color: Colors.blueAccent),
                ),
                style: const TextStyle(fontFamily: 'Poppins'),
                onChanged: (value) {
                  setState(() {
                    _userInput = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _checkAnswer,
                child: const Text("Submit", style: TextStyle(fontFamily: 'Poppins', color: Colors.blue)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue.shade700,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}