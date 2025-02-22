import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'view/auth/login_page.dart';
import 'view/auth/medical_history_page.dart';
import 'view/auth/password_security_page.dart';
import 'view/auth/perso_information_page.dart';
import 'view/auth/primary_caregiver_page.dart';
import 'view/auth/register_page.dart';
import 'view/auth/setup_account_page.dart';
import 'view/home/home_page.dart';
import 'viewmodel/auth_viewmodel.dart';

void main() { 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthViewModel()), // 🔥 Ajout de AuthViewModel
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
        theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.blue,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => LoginPage(),
          '/register': (context) => RegisterPage(),
          '/home': (context) => HomePage(),
          '/passwordSecurity': (context) => PasswordSecurityPage(),
           '/personalInformation': (context) => PersonalInformationPage(),
           '/medicalHistory': (context) => MedicalHistoryPage(),
          '/primaryCaregiver': (context) => PrimaryCaregiverPage(),
          '/setupAccount': (context) => SetupAccountPage(),
        },
      ),
    );
  }
}
