import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';


import '../auth/profile_page.dart';
import 'HealthTrackerPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 16, color: Colors.black),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    const DashboardPage(),
    Center(child: Text("Appointements", style: TextStyle(fontSize: 22))),
    HealthTrackerPage(),
    Center(child: Text("Medications", style: TextStyle(fontSize: 22))),
    ProfilePage(),

  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 10,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: "Appointment"),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Logbook"),
          BottomNavigationBarItem(
              icon: Icon(Icons.medication), label: "Medications"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chatbot"),
        ],
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    "Fatma Abdelkefi",
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.notifications, color: Colors.blue),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 20),
            _upcomingAppointmentCard(),
            const SizedBox(height: 30),
            _activityChartCard(),
            const SizedBox(height: 30),
            _cardsRow(_temperatureCard(), _heartRateCard()),
            const SizedBox(height: 30),
            _cardsRow(_medicationCard(), _dailyCaresCard()),
          ],
        ),
      ),
    );
  }

  Widget _upcomingAppointmentCard() {
    return _genericCard(
        "Upcoming Appointment", Icons.calendar_today, "Dr. Smith - Cardiology",
        showButton: true);
  }

  Widget _activityChartCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 12,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Activity (Last 7 Days)",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          const days = [
                            'Mon',
                            'Tue',
                            'Wed',
                            'Thu',
                            'Fri',
                            'Sat',
                            'Sun'
                          ];
                          return Text(days[value.toInt()],
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold));
                        },
                      ),
                    ),
                  ),
                  barGroups: List.generate(7, (index) {
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                            toY: (5 + index * 2).toDouble(),
                            color: Colors.blue,
                            width: 12),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardsRow(Widget card1, Widget card2) {
    return Row(
      children: [
        Expanded(child: card1),
        const SizedBox(width: 10),
        Expanded(child: card2),
      ],
    );
  }

  Widget _temperatureCard() {
    return _genericCard("Temperature", Icons.thermostat, "36.5°C");
  }

  Widget _heartRateCard() {
    return _genericCard("Heart Rate", Icons.favorite, "75 bpm");
  }

  Widget _medicationCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 12,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12), // Even smaller padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Medication",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16), // Smaller font size
            ),
            const SizedBox(height: 8), // Reduced spacing
            Center(
              child: SizedBox(
                height: 80, // Even smaller size for the pie chart
                width: 80, // Even smaller size for the pie chart
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 0, // No space between sections
                    centerSpaceRadius: 20, // Smaller center hole
                    sections: [
                      PieChartSectionData(
                        value: 80, // 80% taken
                        color: Colors.blue,
                        radius: 30, // Smaller radius for the sections
                        title: '80%', // Display text inside the section
                        titleStyle: const TextStyle(
                          fontSize: 12, // Smaller font size
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      PieChartSectionData(
                        value: 20, // 20% remaining
                        color: Colors.grey[300]!,
                        radius: 30, // Smaller radius for the sections
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 11), // Reduced spacing
            // Legend for "Taken" (blue)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8, // Even smaller size for the blue circle
                  height: 8, // Even smaller size for the blue circle
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4), // Reduced spacing
                const Text(
                  "Taken", // Text to display
                  style: TextStyle(
                      fontSize: 10, color: Colors.blue), // Smaller font size
                ),
              ],
            ),
            const SizedBox(height: 4), // Spacing between the two legends
            // Legend for "Pending" (grey)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8, // Even smaller size for the grey circle
                  height: 8, // Even smaller size for the grey circle
                  decoration: BoxDecoration(
                    color: Colors.grey[300], // Grey color for pending
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4), // Reduced spacing
                const Text(
                  "Pending", // Text to display
                  style: TextStyle(
                      fontSize: 10, color: Colors.grey), // Smaller font size
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dailyCaresCard() {
    return _genericCard("Daily Care", Icons.health_and_safety, "Completed: 80%",
        showButton: false);
  }

  Widget _genericCard(String title, IconData icon, String value,
      {bool showButton = false}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 12,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(icon, size: 40, color: Colors.blue),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(value,
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            if (showButton)
              ElevatedButton(onPressed: () {}, child: const Text("Reschedule")),
          ],
        ),
      ),
    );
  }
}
