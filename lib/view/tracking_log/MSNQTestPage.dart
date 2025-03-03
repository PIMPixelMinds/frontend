import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AppColors {
  static const Color primaryBlue = Color(0xFF3c84fb);
  static const Color darkGrey = Color(0xFF393939);
}

class MSNQTestPage extends StatefulWidget {
  const MSNQTestPage({super.key});

  @override
  _MSNQTestPageState createState() => _MSNQTestPageState();
}

class _MSNQTestPageState extends State<MSNQTestPage> {
  final Map<int, String> _answers = {};
  bool _showResults = false;
  int yesCount = 0;
  int noCount = 0;

  final List<String> _questions = [
    "Do you often forget where you placed objects?",
    "Do you have difficulty concentrating for long periods?",
    "Do you frequently lose track of conversations?",
    "Do you struggle to recall recent events?",
    "Do you find it difficult to follow instructions?",
    "Do you have trouble organizing daily tasks?",
    "Do you feel slower at processing information?",
    "Do you have difficulty multitasking?",
    "Do you often forget appointments or deadlines?",
    "Do you feel mentally fatigued more than usual?",
  ];

  void _submitAnswers() {
    yesCount = _answers.values.where((ans) => ans == "Yes").length;
    noCount = _answers.length - yesCount;

    setState(() {
      _showResults = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MSNQ Test',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            
          ),
        ),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "MS Neuropsychological Questionnaire",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                
                color: AppColors.darkGrey,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Q${index + 1}: ${_questions[index]}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: RadioListTile<String>(
                                  activeColor: AppColors.primaryBlue,
                                  title: const Text(
                                    "Yes",
                                    style: TextStyle(fontFamily: 'Poppins'),
                                  ),
                                  value: "Yes",
                                  groupValue: _answers[index],
                                  onChanged: (value) {
                                    setState(() {
                                      _answers[index] = value!;
                                    });
                                  },
                                ),
                              ),
                              Expanded(
                                child: RadioListTile<String>(
                                  activeColor: Colors.redAccent,
                                  title: const Text(
                                    "No",
                                    style: TextStyle(fontFamily: 'Poppins'),
                                  ),
                                  value: "No",
                                  groupValue: _answers[index],
                                  onChanged: (value) {
                                    setState(() {
                                      _answers[index] = value!;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _submitAnswers,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 5,
              ),
              child: const Text(
                "Submit",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_showResults) _buildResultsChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsChart() {
    return Column(
      children: [
        const Text(
          'Your Test Results',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: 40,
              sections: [
                PieChartSectionData(
                  color: AppColors.primaryBlue,
                  value: yesCount.toDouble(),
                  title: '$yesCount Yes',
                  radius: 25,
                  titleStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  color: Colors.grey,
                  value: noCount.toDouble(),
                  title: '$noCount No',
                  radius: 25,
                  titleStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            legendCircle(AppColors.primaryBlue),
            const SizedBox(width: 5),
            const Text("Yes", style: TextStyle(fontFamily: 'Poppins')),
            const SizedBox(width: 15),
            legendCircle(Colors.grey),
            const SizedBox(width: 5),
            const Text("No", style: TextStyle(fontFamily: 'Poppins')),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget legendCircle(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
