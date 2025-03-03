<<<<<<< Updated upstream:lib/view/tracking_log/CognitiveTrackerPage.dart
import 'package:flutter/material.dart';
import 'MemoryMatchPage.dart';
import 'MSNQTestPage.dart';
import 'PASATTestPage.dart';
import 'SDMTTestPage.dart';
import 'ChartDetailPage.dart';
import 'auditifwordGame.dart';
import 'wordGame.dart';

class AppColors {
  static const Color primaryBlue = Color(0xFF3c84fb);
  static const Color darkGrey = Color(0xFF393939);
}

class CognitiveTrackerPage extends StatefulWidget {
  const CognitiveTrackerPage({super.key});

  @override
  _CognitiveTrackerPageState createState() => _CognitiveTrackerPageState();
}

class _CognitiveTrackerPageState extends State<CognitiveTrackerPage> {
  int _msnqScore = 0;
  int _sdmtScore = 0;
  int _pasatScore = 0;

  void _startTest(BuildContext context, Widget testPage) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        int progress = 0;
        return StatefulBuilder(
          builder: (context, setState) {
            Future.delayed(const Duration(milliseconds: 50), () {
              if (progress < 100) {
                setState(() {
                  progress += 5;
                });
              } else {
                Navigator.pop(context);
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => testPage));
              }
            });

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    value: progress / 100,
                    color: AppColors.primaryBlue,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Loading... $progress%",
                    style: const TextStyle(fontFamily: 'Poppins'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTestSection('MS Neuropsychological Questionnaire (MSNQ)',
                _msnqScore, () => _startTest(context, const MSNQTestPage())),
            _buildTestSection('Symbol Digit Modalities Test (SDMT)', _sdmtScore,
                    () => _startTest(context, const SDMTTestPage())),
            _buildTestSection('Paced Auditory Serial Addition Test (PASAT)',
                _pasatScore, () => _startTest(context, const PASATTestPage())),
            _buildMemoryAndWordGameRow(),
            const SizedBox(height: 20),
            _buildShapeGameCard(),
            const SizedBox(height: 20),
            _buildConsultChartsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildTestSection(String title, int score, VoidCallback onPressed) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 10),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            title: Text(
              '$title Score: $score',
              style: const TextStyle(fontFamily: 'Poppins'),
            ),
            trailing: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: const Text(
                'Take Test',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildMemoryAndWordGameRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildGameCard(
          title: 'Memory Match Game',
          imagePath: 'assets/memgame.png',
          buttonText: 'Play Memory Game',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MemoryMatchPage()),
            );
          },
        ),
        _buildGameCard(
          title: 'Word Game',
          imagePath: 'assets/wordgame.png',
          buttonText: 'Play Word Game',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WordGamePage()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildShapeGameCard() {
    return Center(
      child: _buildGameCard(
        title: 'Shape Game',
        imagePath: 'assets/shapegame.png',
        buttonText: 'Play Shape Game',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) =>  AuditifWordGame()),
          ); // Navigate to Shape Game Page (replace with actual navigation logic)
        },
      ),
    );
  }

  Widget _buildGameCard({
    required String title,
    required String imagePath,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Image.asset(
            imagePath,
            width: 150,
            height: 120,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: Text(
              buttonText,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildConsultChartsCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Consult Charts',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChartDetailPage()),
            );
          },
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'Tap to view detailed charts',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
=======
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'MemoryMatchPage.dart'; // Import MemoryMatchPage
import 'MSNQTestPage.dart';
import 'PASATTestPage.dart';
import 'SDMTTestPage.dart';
import 'ChartDetailPage.dart'; // Create a new page for chart details

class AppColors {
  static const Color primaryBlue = Color(0xFF3c84fb);
  static const Color darkGrey = Color(0xFF393939);
}

class CognitiveTrackerPage extends StatefulWidget {
  const CognitiveTrackerPage({super.key});

  @override
  _CognitiveTrackerPageState createState() => _CognitiveTrackerPageState();
}

class _CognitiveTrackerPageState extends State<CognitiveTrackerPage> {
  final int _msnqScore = 0;
  final int _sdmtScore = 0;
  final int _pasatScore = 0;

  void _startTest(BuildContext context, Widget testPage) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        int progress = 0;
        return StatefulBuilder(
          builder: (context, setState) {
            Future.delayed(const Duration(milliseconds: 50), () {
              if (progress < 100) {
                setState(() {
                  progress += 5;
                });
              } else {
                Navigator.pop(context);
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => testPage));
              }
            });

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    value: progress / 100,
                    color: AppColors.primaryBlue,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Loading... $progress%",
                    style: const TextStyle(fontFamily: 'Poppins'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTestSection('MS Neuropsychological Questionnaire (MSNQ)',
                _msnqScore, () => _startTest(context, const MSNQTestPage())),
            _buildTestSection('Symbol Digit Modalities Test (SDMT)', _sdmtScore,
                () => _startTest(context, const SDMTTestPage())),
            _buildTestSection('Paced Auditory Serial Addition Test (PASAT)',
                _pasatScore, () => _startTest(context, const PASATTestPage())),
            _buildMemoryGameCard(),
            const SizedBox(height: 20),
            _buildConsultChartsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildTestSection(String title, int score, VoidCallback onPressed) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 10),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            title: Text(
              '$title Score: $score',
              style: const TextStyle(fontFamily: 'Poppins'),
            ),
            trailing: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: const Text(
                'Take Test',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildMemoryGameCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Memory Match Game',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 10),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Image.asset(
                'assets/memgame.png', // Place your image in the assets folder
                width: 300, // Adjust the width as needed
                height: 200, // Adjust the height as needed
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MemoryMatchPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: const Text(
                  'Play Memory Game',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildConsultChartsCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Consult Charts',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChartDetailPage()),
            );
          },
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'Tap to view detailed charts',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
>>>>>>> Stashed changes:lib/view/home/CognitiveTrackerPage.dart
