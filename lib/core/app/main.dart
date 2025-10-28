import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../firebase/firebase_options.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/home/screens/home_page.dart';
import '../../features/auth/screens/login_page.dart';
import '../../features/auth/screens/signup_page.dart';
import '../../features/maps/screens/map_page.dart';
import '../../features/maps/screens/pick_location_map_page.dart';
import '../../features/video/screens/video_player.dart';
import '../../features/video/screens/video_player_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Ignore duplicate-app error
    if (e.toString().contains(
      'A Firebase App named "[DEFAULT]" already exists',
    )) {
      // Already initialized, safe to continue
    } else {
      rethrow;
    }
  }
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
        '/map': (context) => const MapPage(),
        '/pick-location': (context) => const PickLocationMapPage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/video-player': (context) => const YouTubeStyleUploader(),
        // Route for the YouTube-style player/list page
        '/videos': (context) => const VideoPlayerPage(),
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
