import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'splash_screen.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'signup_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
      },
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: const Color.fromARGB(255, 118, 118, 165),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 114, 114, 119),
          elevation: 0,
        ),
      ),
    );
  }
}
