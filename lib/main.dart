import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:pim/firebase_options.dart';
import 'package:pim/viewmodel/appointment_viewmodel.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'view/auth/login_page.dart';
import 'view/auth/medical_history_page.dart';
import 'view/auth/password_security_page.dart';
import 'view/auth/perso_information_page.dart';
import 'view/auth/primary_caregiver_page.dart';
import 'view/auth/register_page.dart';
import 'view/auth/setup_account_page.dart';
import 'view/home/home_page.dart';
import 'viewmodel/auth_viewmodel.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => AppointmentViewModel())
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: AppColors.primaryBlue,
          fontFamily: 'Montserrat',
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: AppColors.primaryBlue,
          fontFamily: 'Montserrat',
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
          //'/setupAccount': (context) => SetupAccountPage(),
        },
      ),
    );
  }
}
