import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:pim/view/appointment/appointment_view.dart';
import '../../core/constants/app_colors.dart';
import '../auth/profile_page.dart';
import '../body/body_page.dart';
import '../tracking_log/HealthTrackerPage.dart';
import 'Chatbot.dart';
import 'dart:ui';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
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
  final List<Widget> _pages = <Widget>[
    const DashboardPage(),
    AppointmentPage(),
    BodyPage(),
    HealthTrackerPage(),
    Center(child: Text("Medications", style: TextStyle(fontSize: 22))),
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
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        color: AppColors.primaryBlue,
        buttonBackgroundColor: AppColors.primaryBlue,
        animationDuration: Duration(milliseconds: 300),
        items: const [
          Icon(Icons.dashboard,
              size: 30, color: Colors.white), // Accueil / Dashboard
          Icon(Icons.event, size: 30, color: Colors.white), // Rendez-vous
          Icon(Icons.accessibility_new,
              size: 30, color: Colors.white), // Corps humain
          Icon(Icons.monitor_heart,
              size: 30, color: Colors.white), // Suivi de santé
          Icon(Icons.local_pharmacy,
              size: 30, color: Colors.white), // Médicaments
        ],
      ),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;
  final List<String> _appointments = [
    "Dr. Smith - Cardiology",
    "Dr. Lee - Dermatology",
    "Dr. Adams - Neurology"
  ];

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title:
            const Text("Home", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryBlue,
        actions: [
          IconButton(
            icon:
                const Icon(Icons.notifications, size: 30, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon:
                const Icon(Icons.account_circle, size: 30, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Column(
              children: [
                CarouselSlider.builder(
                  itemCount: _appointments.length,
                  itemBuilder: (context, index, realIndex) {
                    return Opacity(
                      opacity: _currentIndex == index ? 1.0 : 0.5,
                      child: _appointmentCard(_appointments[index], isDarkMode),
                    );
                  },
                  options: CarouselOptions(
                    height: 200, // Increased card height
                    enlargeCenterPage: true,
                    viewportFraction:
                        0.5, // Shows more of previous and next items
                    onPageChanged: (index, reason) {
                      setState(() => _currentIndex = index);
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_appointments.length, (index) {
                    return Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentIndex == index
                            ? AppColors.primaryBlue
                            : Colors.grey,
                      ),
                    );
                  }),
                )
              ],
            ),
            const SizedBox(height: 30),
            _activityChartCard(),
            const SizedBox(height: 30),
            _cardsRow(_temperatureCard(), _heartRateCard()),
            const SizedBox(height: 30),
            _cardsRow(_medicationCard(), _dailyCaresCard()),
          ],
        ),
      ),
      // Replace the current onPressed method of the FloatingActionButton
      floatingActionButton: Stack(
        children: [
          // Blur effect behind the button
          Positioned(
            bottom: 10, // Adjust position if needed
            right: 10, // Adjust position if needed
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40), // Circular blur area
              child: BackdropFilter(
                filter:
                    ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Blur intensity
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white
                        .withOpacity(0.2), // Light transparent white
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),

          // Floating Action Button with Chatbot Navigation
          Positioned(
            bottom: 15, // Adjust position to align with blur
            right: 15, // Adjust position to align with blur
            child: FloatingActionButton(
              onPressed: () {
                showChatbot(context); // Show the chatbot bottom sheet
              },
              backgroundColor: Colors.white, // Ensure good contrast
              child: Image.asset(
                'assets/chatbot_icon.png', // Replace with your chatbot logo
                width: 40,
                height: 40,
              ),
            ),
          ),
        ],
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

  Widget _appointmentCard(String title, bool isDarkMode) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 12,
      color: isDarkMode ? AppColors.primaryBlue : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Upcoming Appointment",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black)),
            const SizedBox(height: 8),
            Text(title,
                style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.white : Colors.black)),
          ],
        ),
      ),
    );
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
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
                        color: Colors.grey[500]!,
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
                    color: Colors.grey[500], // Grey color for pending
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4), // Reduced spacing
                const Text(
                  "Pending", // Text to display
                  style: TextStyle(
                      fontSize: 10,
                      color: Color.fromARGB(
                          255, 107, 106, 106)), // Smaller font size
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
