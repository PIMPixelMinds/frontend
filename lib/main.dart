import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'view/auth/login_page.dart';
import 'view/home/home_page.dart';
import 'view/auth/register_page.dart';
import 'view/auth/medical_history_page.dart';
import 'view/auth/password_security_page.dart';
import 'view/auth/perso_information_page.dart';
import 'view/auth/primary_caregiver_page.dart';
import 'view/auth/setup_account_page.dart';
import 'view/medication/medications_screen.dart';
import 'view/medication/medicine_info_screen.dart';
import 'view/medication/add_reminder_screen.dart';
import 'viewmodel/auth_viewmodel.dart';
import 'viewmodel/medication_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = (prefs.getBool("rememberMe") ?? false) == true;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthViewModel()),
        ChangeNotifierProvider(create: (context) => MedicationViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: isLoggedIn ? const HomePage() : const LoginPage(),
        themeMode: ThemeMode.system,
        theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.blue,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
        ),
        routes: {
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/home': (context) => const HomePage(),
          '/passwordSecurity': (context) => const PasswordSecurityPage(),
          '/personalInformation': (context) => const PersonalInformationPage(),
          '/medicalHistory': (context) => const MedicalHistoryPage(),
          '/primaryCaregiver': (context) => const PrimaryCaregiverPage(),
          //'/setupAccount': (context) => const SetupAccountPage(),
          '/medications': (context) => const MedicationsScreen(),
          '/medicineInfo': (context) {
            final medicationId = ModalRoute.of(context)!.settings.arguments as String?;
            return MedicineInfoScreen(medicationId: medicationId ?? '');
          },
          '/addReminder': (context) => const AddReminderScreen(),
        },
      ),
    );
  }
}