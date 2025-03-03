<<<<<<< Updated upstream:lib/view/tracking_log/HealthTrackerPage.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/healthTracker_viewmodel.dart';
import 'CognitiveTrackerPage.dart';
import 'package:intl/intl.dart';  // Don't forget to import the intl package for date formatting

class HealthTrackerPage extends StatefulWidget {
  const HealthTrackerPage({super.key});

  @override
  _HealthTrackerPageState createState() => _HealthTrackerPageState();
}

class _HealthTrackerPageState extends State<HealthTrackerPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch activities, upcoming and completed appointments after build
      Provider.of<HealthTrackerViewModel>(context, listen: false)
          .fetchActivities(context);
      Provider.of<HealthTrackerViewModel>(context, listen: false)
          .fetchUpcomingAppointmentsCount(context); // Fetch the count of upcoming appointments
      Provider.of<HealthTrackerViewModel>(context, listen: false)
          .fetchCompletedAppointments(context); // Fetch completed appointments
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<HealthTrackerViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tracking Log',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
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
                fontFamily: 'Poppins',
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
          _buildOverallTab(viewModel),
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

  Widget _buildOverallTab(HealthTrackerViewModel viewModel) {
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
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 16),
          if (viewModel.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (viewModel.errorMessage.isNotEmpty)
            Center(
              child: Text(
                viewModel.errorMessage,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red),
              ),
            )
          else if (viewModel.activities.isEmpty)
              const Center(
                child: Text("No activities available.",
                    style: TextStyle(fontSize: 16, fontFamily: 'Poppins')),
              )
            else
              Column(
                children: viewModel.activities.map((activity) {
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
                        fontFamily: 'Poppins',
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
                  child: Column(
                    children: [
                      const Text(
                        'Upcoming Appointments',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${viewModel.upcomingAppointmentsCount}', // Dynamic upcoming count
                        style: const TextStyle(
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
          // Completed Appointments section - positioned under the row
          const Text(
            'Completed Appointments',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 10),
          _buildCompletedAppointments(viewModel),
        ],
      ),
    );
  }

  Widget _buildCompletedAppointments(HealthTrackerViewModel viewModel) {
    return Column(
      children: viewModel.completedAppointments.map((appointment) {
        final doctor = appointment['fullName'] ?? "Unknown Doctor";
        final date = appointment['date'] ?? "Unknown Date";
        final formattedTime = _formatDate(date);

        return appointmentCard(doctor, formattedTime, true);
      }).toList(),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final dateTime = DateTime.parse(dateStr);
      final formatter = DateFormat('yyyy-MM-dd HH:mm');
      return formatter.format(dateTime);
    } catch (e) {
      print('Error formatting date: $e');
      return dateStr;
    }
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

  // Appointment Card Widget (for completed appointments with a Done icon)
  Widget appointmentCard(String doctor, String time, [bool isCompleted = false]) {
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
        trailing: isCompleted
            ? const Icon(Icons.check_circle, color: Colors.green, size: 24)
            : const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue),
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
=======
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'CognitiveTrackerPage.dart';

class HealthTrackerPage extends StatefulWidget {
  const HealthTrackerPage({super.key});

  @override
  _HealthTrackerPageState createState() => _HealthTrackerPageState();
}

class _HealthTrackerPageState extends State<HealthTrackerPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
            fontFamily: 'Poppins',
          ),
        ),
        actions: const [
          Icon(Icons.notifications_none, size: 28),
          SizedBox(width: 16),
          Icon(Icons.settings, size: 28),
          SizedBox(width: 16),
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
              indicatorPadding:
                  const EdgeInsets.symmetric(vertical: 5), // Add padding
              indicatorSize: TabBarIndicatorSize
                  .tab, // Ensure the indicator covers the tab
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black54,
              labelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
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
          const CognitiveTrackerPage(),
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
          // Suggested Activities
          const Text(
            'Suggested Activities',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              activityCard(
                  "Morning Walk", "Start your day with a 30-minute walk."),
              activityCard(
                  "Yoga Session", "Practice relaxation and breathing."),
              activityCard(
                  "Hydration Goal", "Drink at least 8 glasses of water."),
              activityCard(
                  "Healthy Eating", "Include more fruits & veggies in meals."),
            ],
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
                        fontFamily: 'Poppins',
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
                          fontFamily: 'Poppins',
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
              fontFamily: 'Poppins',
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

  // Activity Card Widget
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
>>>>>>> Stashed changes:lib/view/home/HealthTrackerPage.dart
