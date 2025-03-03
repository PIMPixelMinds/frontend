import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class MemoryMatchPage extends StatefulWidget {
  const MemoryMatchPage({super.key});

  @override
  _MemoryMatchPageState createState() => _MemoryMatchPageState();
}

class _MemoryMatchPageState extends State<MemoryMatchPage> {
  List<String> _cards = [];
  List<bool> _cardFlips = List.generate(16, (index) => false);
  List<int> _cardValues = List.generate(16, (index) => 0);
  int _matchedCount = 0;
  int _score = 0;
  int _moves = 0;
  bool _isFirstClick = true;
  int _firstCardIndex = -1;
  int _secondCardIndex = -1;
  late Timer _showCardsTimer;
  late Timer _gameTimer;
  int _showCardsTime = 5;  // Time for showing cards at the start
  int _remainingTime = 60;  // Game time
  bool _isRevealing = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  @override
  void dispose() {
    _showCardsTimer.cancel();
    _gameTimer.cancel();
    super.dispose();
  }

  void _initializeGame() {
    _cards = List.generate(8, (index) => (index + 1).toString())
      ..addAll(List.generate(8, (index) => (index + 1).toString()))
      ..shuffle(Random());

    _cardFlips = List.generate(16, (index) => true);
    _initializeCardValues();

    // Start the show cards timer
    _startShowCardsTimer();
  }

  void _initializeCardValues() {
    for (int i = 0; i < 16; i++) {
      _cardValues[i] = int.parse(_cards[i]);
    }
  }

  // Show Cards Timer - for revealing cards at the start of the game
  void _startShowCardsTimer() {
    _showCardsTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_showCardsTime > 0) {
        setState(() {
          _showCardsTime--;
        });
      } else {
        _showCardsTimer.cancel();
        _startGameTimer();
        setState(() {
          _cardFlips = List.generate(16, (index) => false);  // Hide the cards after showing
          _isRevealing = false;  // Begin the game
        });
      }
    });
  }

  // Game Timer - for countdown while playing the game
  void _startGameTimer() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        _gameTimer.cancel();
        _showGameOverDialog();
      }
    });
  }

  void _flipCard(int index) {
    if (_cardFlips[index] || _isRevealing || _isProcessing) return;

    setState(() {
      _cardFlips[index] = true;
      if (_isFirstClick) {
        _firstCardIndex = index;
        _isFirstClick = false;
      } else {
        _secondCardIndex = index;
        _moves++;
        _isProcessing = true;

        if (_cardValues[_firstCardIndex] == _cardValues[_secondCardIndex]) {
          _matchedCount++;
          _score += 10;
          _resetSelection();

          if (_matchedCount == 8) {
            _gameTimer.cancel();
            _showGameOverDialog();
          }
        } else {
          Future.delayed(const Duration(seconds: 1), () {
            setState(() {
              _cardFlips[_firstCardIndex] = false;
              _cardFlips[_secondCardIndex] = false;
              _resetSelection();
            });
          });
        }
      }
    });
  }

  void _resetSelection() {
    _firstCardIndex = -1;
    _secondCardIndex = -1;
    _isFirstClick = true;
    _isProcessing = false;
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.blueAccent.shade100,
          title: const Text(
            'Game Over',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Your Score: $_score',
                style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                'Moves: $_moves',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              Text(
                'Time Left: $_remainingTime seconds',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text(
                'Back to Menu',
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Memory Match Game',style: TextStyle(fontFamily: 'Poppins', fontSize: 22, fontWeight: FontWeight.bold),

      ),
        backgroundColor: const Color(0xFF3c84fb),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade700, Colors.blue.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGameInfo(),
              const SizedBox(height: 20),
              _buildShowCardsTimer(),
              const SizedBox(height: 20),
              _buildGameTimerWidget(), // Displaying the Game Timer here
              const SizedBox(height: 20),
              _buildCardGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildInfoBox('Score', '$_score'),
        _buildInfoBox('Moves', '$_moves'),
      ],
    );
  }

  Widget _buildInfoBox(String title, String value) {
    return Card(
      color: Colors.white.withOpacity(0.8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
          ],
        ),
      ),
    );
  }

  Widget _buildShowCardsTimer() {
    return Center(
      child: Text(
        'Show Cards Time: $_showCardsTime', // Time left for showing the cards
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade800, // Dark gray color for the timer text
        ),
      ),
    );
  }

  Widget _buildGameTimerWidget() {
    return Center(
      child: Text(
        'Game Time Left: $_remainingTime', // Time left for the game
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade300, // Dark gray color for the timer text
        ),
      ),
    );
  }

  Widget _buildCardGrid() {
    return Expanded(
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: 16,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _flipCard(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: _cardFlips[index] ? Colors.white : const Color(0xFF3c84fb),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 5,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: _cardFlips[index]
                    ? Icon(_getCardIcon(_cards[index]), size: 40, color: Colors.black)
                    : const SizedBox.shrink(),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getCardIcon(String value) {
    return [Icons.ac_unit, Icons.access_alarm, Icons.account_balance, Icons.airport_shuttle, Icons.assignment, Icons.assessment, Icons.attach_money, Icons.business][int.parse(value) - 1];
  }
}
