import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class WordGamePage extends StatefulWidget {
  const WordGamePage({super.key});

  @override
  _WordGamePageState createState() => _WordGamePageState();
}

class _WordGamePageState extends State<WordGamePage> {
  final List<String> allWords = [
    'Apple', 'Banana', 'Orange', 'Grapes', 'Watermelon',
    'Strawberry', 'Pineapple', 'Mango', 'Peach', 'Blueberry',
    'Carrot', 'Tomato', 'Potato', 'Cucumber', 'Lemon',
    'Lettuce', 'Onion', 'Pumpkin', 'Cabbage', 'Radish'
  ];

  List<String> shownWords = [];
  List<String> choices = [];
  Set<String> selectedWords = {};
  bool showSelectionScreen = false;
  Timer? timer;
  int secondsLeft = 10;
  int score = 0;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    shownWords = List.from(allWords)..shuffle();
    shownWords = shownWords.sublist(0, 10);
    choices = List.from(allWords)..shuffle();
    _startTimer();
  }

  void _startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {
        if (secondsLeft > 1) {
          secondsLeft--;
        } else {
          t.cancel();
          setState(() {
            showSelectionScreen = true;
          });
        }
      });
    });
  }

  void _checkAnswers() {
    score = selectedWords.where((word) => shownWords.contains(word)).length;
    _showResultDialog(score);
  }

  void _showResultDialog(int score) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          "Results",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "You remembered $score out of 10 words!",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  showSelectionScreen = false;
                  secondsLeft = 10;
                  selectedWords.clear();
                  _startGame();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Play Again", style: TextStyle(fontSize: 18, color: Colors.white, fontFamily: 'Poppins')),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Word Memory Game", style: TextStyle(fontFamily: 'Poppins', fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[700]!, Colors.white], // Blue and White Gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: showSelectionScreen ? _buildSelectionScreen() : _buildWordDisplayScreen(),
          ),
        ),
      ),
    );
  }

  Widget _buildWordDisplayScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Timer at the top
        AnimatedOpacity(
          opacity: secondsLeft > 0 ? 1.0 : 0.0,
          duration: const Duration(seconds: 1),
          child: Text(
            "$secondsLeft",
            style: TextStyle(
              fontSize: 80,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
              fontFamily: 'Poppins',
              shadows: [
                Shadow(
                  blurRadius: 15.0,
                  color: Colors.blue[800]!.withOpacity(0.6),
                  offset: const Offset(0, 0),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20), // Space between timer and words
        const Text(
          "Memorize These Words",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, fontFamily: 'Poppins', color: Colors.black),
        ),
        const SizedBox(height: 40), // Space between text and words
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: shownWords
              .map((word) => Chip(
            label: Text(word, style: const TextStyle(fontSize: 18, fontFamily: 'Poppins', color: Colors.white)),
            backgroundColor: Colors.blue[200],
          ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildSelectionScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Select the Words You Remember",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Poppins', color: Colors.black45),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: choices.map((word) {
            bool isSelected = selectedWords.contains(word);
            return ChoiceChip(
              label: Text(word, style: const TextStyle(fontSize: 16, fontFamily: 'Poppins', color: Colors.white)),
              selected: isSelected,
              selectedColor: Colors.greenAccent,
              backgroundColor: Colors.grey[400],
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    selectedWords.add(word);
                  } else {
                    selectedWords.remove(word);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _checkAnswers,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text("Submit", style: TextStyle(fontSize: 18, color: Colors.white, fontFamily: 'Poppins')),
        ),
      ],
    );
  }
}
