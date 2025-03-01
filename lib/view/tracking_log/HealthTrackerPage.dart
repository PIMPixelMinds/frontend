import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/repositories/ai_service.dart';
import 'CognitiveTrackerPage.dart';

class HealthTrackerPage extends StatefulWidget {
  const HealthTrackerPage({super.key});

  @override
  _HealthTrackerPageState createState() => _HealthTrackerPageState();
}

class _HealthTrackerPageState extends State<HealthTrackerPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, String>> activities = [];
  bool isLoading = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchActivities();
  }

  Future<void> fetchActivities() async {
  if (!mounted) return; // Prevents setState() if the widget is disposed

  setState(() {
    isLoading = true;
    errorMessage = '';
  });

  try {
    AIService aiService = AIService();
    final fetchedActivities = await aiService.getActivities();

    if (!mounted) return; // Check again after async call
    setState(() {
      activities = fetchedActivities;
      if (fetchedActivities.isEmpty) {
        errorMessage = "No activities available.";
      }
    });
  } catch (e) {
    if (!mounted) return; // Avoid calling setState if disposed
    setState(() => errorMessage = "Error: $e");
  }

  if (!mounted) return;
  setState(() => isLoading = false);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tracking Log',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 28),
            onPressed: fetchActivities,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(25),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(25),
              ),
              indicatorPadding: const EdgeInsets.symmetric(vertical: 5),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black54,
              labelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                
              ),
              tabs: const [
                Tab(text: "Cognitive"),
                Tab(text: "Overall"),
                Tab(text: "Health"),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          CognitiveTrackerPage(),
          _buildOverallTab(),
          _emptyTab("Health Progress Data Here"),
        ],
      ),
    );
  }

  Widget _emptyTab(String text) {
    return Center(
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildOverallTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Suggested Activities',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              
            ),
          ),
          const SizedBox(height: 16),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (errorMessage.isNotEmpty)
            Center(
              child: Text(
                errorMessage,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red),
              ),
            )
          else if (activities.isEmpty)
            const Center(
              child: Text("No activities available.",
                  style: TextStyle(fontSize: 16, fontFamily: 'Poppins')),
            )
          else
            Column(
              children: activities.map((activity) {
                final title = activity['activity'] ?? "Unknown Activity";
                final description =
                    activity['description'] ?? "No description available.";
                return activityCard(title, description);
              }).toList(),
            ),

          const SizedBox(height: 24),

          // Row for Medication Overview & Total Appointments
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'Medication Overview',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        
                      ),
                    ),
                    const SizedBox(height: 8),
                    AspectRatio(
                      aspectRatio: 1.3,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 0,
                          centerSpaceRadius: 40,
                          sections: [
                            PieChartSectionData(
                              color: const Color(0xFF3c84fb),
                              value: 70,
                              title: '70%',
                              radius: 25,
                              titleStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            PieChartSectionData(
                              color: Colors.grey,
                              value: 30,
                              title: '30%',
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
                    // Medication Legend
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        legendCircle(Colors.blue),
                        const SizedBox(width: 5),
                        const Text("Taken",
                            style: TextStyle(fontFamily: 'Poppins')),
                        const SizedBox(width: 15),
                        legendCircle(Colors.grey),
                        const SizedBox(width: 5),
                        const Text("Pending",
                            style: TextStyle(fontFamily: 'Poppins')),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF393939), // Dark background
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        'Total Appointments Done',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '12', // Static total appointments count
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          const Text(
            'Upcoming Appointments',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              
            ),
          ),

          const SizedBox(height: 8),

          // Static Appointments List
          appointmentCard("Dr. Smith (Neurologist)", "Tue, 10:00 AM"),
          appointmentCard("Dr. Miller (Physiotherapist)", "Thu, 2:00 PM"),
        ],
      ),
    );
  }

  Widget activityCard(String title, String description) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: const Icon(Icons.fitness_center, color: Colors.blue),
        title: Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins')),
        subtitle: Text(description,
            style: const TextStyle(fontSize: 14, fontFamily: 'Poppins')),
      ),
    );
  }

  // Appointment Card Widget
  Widget appointmentCard(String doctor, String time) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.calendar_today, color: Color(0xFF3c84fb)),
        title: Text(
          doctor,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
        ),
        subtitle: Text(
          time,
          style: const TextStyle(fontSize: 14, fontFamily: 'Poppins'),
        ),
        trailing:
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue),
      ),
    );
  }

  // Medication Legend Circle Widget
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