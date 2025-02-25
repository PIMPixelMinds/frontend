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
  late Timer _timer;
  int _remainingTime = 60;
  bool _isRevealing = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _initializeGame() {
    _cards = List.generate(8, (index) => (index + 1).toString())
      ..addAll(List.generate(8, (index) => (index + 1).toString()))
      ..shuffle(Random());

    _cardFlips = List.generate(16, (index) => true);
    _initializeCardValues();

    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        _cardFlips = List.generate(16, (index) => false);
        _isRevealing = false;
        _startTimer();
      });
    });
  }

  void _initializeCardValues() {
    for (int i = 0; i < 16; i++) {
      _cardValues[i] = int.parse(_cards[i]);
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        _timer.cancel();
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
            _timer.cancel();
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
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text('Game Over', style: TextStyle(fontFamily: 'Poppins')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Your Score: $_score', style: const TextStyle(fontFamily: 'Poppins')),
              Text('Moves: $_moves', style: const TextStyle(fontFamily: 'Poppins')),
              Text('Time Left: $_remainingTime seconds', style: const TextStyle(fontFamily: 'Poppins')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Back to Menu', style: TextStyle(fontFamily: 'Poppins')),
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
        title: const Text('Memory Match Game', style: TextStyle(fontFamily: 'Poppins')),
        backgroundColor: const Color(0xFF3c84fb),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGameInfo(),
            const SizedBox(height: 20),
            _buildCardGrid(),
          ],
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
        _buildInfoBox('Time Left', '$_remainingTime s'),
      ],
    );
  }

  Widget _buildInfoBox(String title, String value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
      ],
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
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 4,
              color: _cardFlips[index] ? Colors.white : const Color(0xFF3c84fb),
              child: Center(
                child: _cardFlips[index] ? Icon(_getCardIcon(_cards[index]), size: 40, color: Colors.black) : const SizedBox.shrink(),
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