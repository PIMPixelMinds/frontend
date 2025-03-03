import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:pim/view/appointment/appointment_view.dart';
import '../../core/constants/app_colors.dart';
import '../auth/profile_page.dart';
import '../body/body_page.dart';
import '../tracking_log/HealthTrackerPage.dart';

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
            onPressed: () {
              // Ajoute ici la navigation vers les notifications
            },
          ),
          IconButton(
            icon:
                const Icon(Icons.account_circle, size: 30, color: Colors.white),
            onPressed: () {
              // Ajoute ici la navigation vers la page de profil
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
                CarouselSlider(
                  items: _appointments
                      .map((appt) => _appointmentCard(appt, isDarkMode))
                      .toList(),
                  options: CarouselOptions(
                    height: 120,
                    enlargeCenterPage: true,
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
            _activityChartCard(isDarkMode),
            const SizedBox(height: 30),
            _cardsRow(_temperatureCard(isDarkMode), _heartRateCard(isDarkMode)),
            const SizedBox(height: 30),
            _cardsRow(_medicationCard(isDarkMode), _dailyCaresCard(isDarkMode)),
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

  Widget _activityChartCard(bool isDarkMode) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 12,
      color: isDarkMode ? Colors.black : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 200,
          child: BarChart(BarChartData(
            borderData: FlBorderData(show: false),
            barGroups: List.generate(7, (index) {
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: (5 + index * 2).toDouble(),
                    color:
                        isDarkMode ? AppColors.primaryBlue : Colors.lightBlue,
                    width: 12,
                  ),
                ],
              );
            }),
          )),
        ),
      ),
    );
  }

  Widget _temperatureCard(bool isDarkMode) =>
      _infoCard("Temperature", Icons.thermostat_outlined, "36.5°C", isDarkMode);
  Widget _heartRateCard(bool isDarkMode) => _infoCard(
      "Heart Rate", Icons.monitor_heart_outlined, "75 bpm", isDarkMode);
  Widget _medicationCard(bool isDarkMode) => _infoCard(
      "Medication", Icons.medication_outlined, "80% Taken", isDarkMode);
  Widget _dailyCaresCard(bool isDarkMode) => _infoCard(
      "Daily Care", Icons.check_circle_outline, "Completed: 80%", isDarkMode);

  Widget _infoCard(String title, IconData icon, String value, bool isDarkMode) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 12,
      color: isDarkMode ? AppColors.primaryBlue : Colors.white,
      child: ListTile(
        leading: Icon(icon,
            color: isDarkMode ? Colors.white : AppColors.primaryBlue),
        title: Text(title,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black)),
        subtitle: Text(value,
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
      ),
    );
  }
}
