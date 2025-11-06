import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'dart:ui';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:latlong2/latlong.dart' show LatLng;

// Weather service
import '../../weather/services/weather_api.dart';

// Device screens
import '../../devices/screens/room_detail_page.dart';
import '../../devices/screens/thermostat_config_page.dart';
import '../../devices/screens/smart_light_page.dart';
import '../../devices/screens/smart_plug_page.dart';
import '../../devices/screens/smart_tv_page.dart';
import '../../devices/screens/air_conditioner_page.dart';

// Device widgets
import '../../devices/widgets/device_card.dart';

// Profile
import '../../profile/screens/profile_page.dart';

part 'home_page.navbar_painter.dart';
part 'home_page.forecast_strip.dart';
part 'home_page.mic_button.dart';
part 'home_page.header.dart';
part 'home_page.weather_card.dart';
part 'home_page.tabs.dart';
part 'home_page.content.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with _HomePageHeader, _HomePageTabs, _HomePageContent {
  int _tabIndex = 0;
  Map<String, dynamic>? _weather;
  Map<String, dynamic>? _forecast;
  bool _loadingWeather = false;
  String? _weatherError;

  final List<Map<String, dynamic>> rooms = [
    {
      "title": "Master Bedroom",
      "devices": "4 devices",
      "image": "assets/bedroom.jpeg",
      "status": true,
    },
    {
      "title": "Living Room",
      "devices": "5 devices",
      "image": "assets/livingroom.jpg",
      "status": false,
    },
    {
      "title": "Kitchen",
      "devices": "5 devices",
      "image": "assets/kitchen.jpeg",
      "status": true,
    },
    {
      "title": "Bathroom",
      "devices": "2 devices",
      "image": "assets/bathroom.jpg",
      "status": false,
    },
  ];

  final List<Map<String, dynamic>> devices = [
    {
      "title": "Smart Light",
      "subtitle": "Living Room",
      "icon": Icons.lightbulb,
      "status": true,
    },
    {
      "title": "Thermostat",
      "subtitle": "Living Room",
      "icon": Icons.thermostat,
      "status": false,
    },
    {
      "title": "Air Conditioner",
      "subtitle": "Bedroom",
      "icon": Icons.ac_unit,
      "status": false,
    },
    {
      "title": "Smart Plug",
      "subtitle": "Kitchen",
      "icon": Icons.power,
      "status": true,
    },
    {
      "title": "Smart TV",
      "subtitle": "Living Room",
      "icon": Icons.tv,
      "status": false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadWeatherUsingGps();
  }

  Future<void> _loadWeather({String city = 'auto:ip'}) async {
    setState(() {
      _loadingWeather = true;
      _weatherError = null;
    });
    try {
      final data = await WeatherApi()
          .fetchCurrentWeather(city)
          .timeout(const Duration(seconds: 10));
      setState(() => _weather = data);
    } catch (e) {
      setState(() => _weatherError = e.toString());
    } finally {
      if (mounted) setState(() => _loadingWeather = false);
    }
  }

  Future<dynamic> _determinePosition() async {
    if (kIsWeb) {
      // On web, just use Geolocator (browser handles permission)
      try {
        final pos = await Geolocator.getCurrentPosition();
        return pos;
      } catch (e) {
        return null;
      }
    } else {
      Location location = Location();
      while (true) {
        bool serviceEnabled = await location.serviceEnabled();
        if (!serviceEnabled) {
          bool? result = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text('Location Required'),
              content: const Text(
                'This app needs location services to be enabled. Would you like to turn it on?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Yes'),
                ),
              ],
            ),
          );
          if (result == true) {
            serviceEnabled = await location.requestService();
            if (!serviceEnabled) continue;
          } else {
            bool? openSettings = await showDialog<bool>(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                title: const Text('Location Needed'),
                content: const Text(
                  'You must enable location in settings to use this feature.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      await Geolocator.openAppSettings();
                      Navigator.of(context).pop(true);
                    },
                    child: const Text('Open Settings'),
                  ),
                ],
              ),
            );
            if (openSettings == true) {
              continue;
            } else {
              return null;
            }
          }
        }

        PermissionStatus permissionGranted = await location.hasPermission();
        if (permissionGranted == PermissionStatus.denied ||
            permissionGranted == PermissionStatus.deniedForever) {
          PermissionStatus requested = await location.requestPermission();
          if (requested != PermissionStatus.granted) {
            bool? openSettings = await showDialog<bool>(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                title: const Text('Location Permission Needed'),
                content: const Text(
                  'You must grant location permission to use this feature.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      await Geolocator.openAppSettings();
                      Navigator.of(context).pop(true);
                    },
                    child: const Text('Open Settings'),
                  ),
                ],
              ),
            );
            if (openSettings == true) {
              continue;
            } else {
              return null;
            }
          }
        }

        // If we reach here, permission and service are enabled
        return await location.getLocation();
      }
    }
  }

  Future<void> _loadWeatherUsingGps() async {
    setState(() {
      _loadingWeather = true;
      _weatherError = null;
    });
    try {
      final pos = await _determinePosition();
      if (pos == null) {
        // fallback to ip-based lookup
        await _loadWeather(city: 'auto:ip');
        return;
      }
      final latlon = '${pos.latitude},${pos.longitude}';
      final data = await WeatherApi()
          .fetchCurrentWeather(latlon)
          .timeout(const Duration(seconds: 10));
      setState(() => _weather = data);
      // also fetch a short forecast for the same lat/lon
      try {
        final fc = await WeatherApi()
            .fetchForecast(latlon, days: 3)
            .timeout(const Duration(seconds: 10));
        if (mounted) setState(() => _forecast = fc);
      } catch (_) {
        // non-fatal: leave _forecast null on error
      }
    } catch (e) {
      setState(() => _weatherError = e.toString());
    } finally {
      if (mounted) setState(() => _loadingWeather = false);
    }
  }

  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 400;

    // 🔧 FAB size relative to screen width
    final double fabSize = (screenWidth * 1).clamp(60.0, 120.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      extendBody: true,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(isSmallScreen),
                  SizedBox(height: isSmallScreen ? 14 : 18),

                  _buildWeatherCard(isSmallScreen),
                  SizedBox(height: isSmallScreen ? 14 : 18),

                  _buildTabs(isSmallScreen),
                  SizedBox(height: isSmallScreen ? 14 : 18),

                  Expanded(child: _buildContent(isSmallScreen)),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: (screenWidth - fabSize * 0.7) / 2,
            child: _MicButton(fabSize: fabSize),
          ),
        ],
      ),

      bottomNavigationBar: SizedBox(
        height: screenHeight * 0.12,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            CustomPaint(
              size: Size(double.infinity, screenHeight * 0.12),
              painter: _NavBarPainter(),
            ),

            Positioned(
              bottom: screenHeight * 0.03,
              left: screenWidth * 0.1,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomePage()),
                    (route) => false,
                  );
                },
                child: Icon(
                  Icons.home_outlined,
                  size: isSmallScreen ? 28 : 32,
                  color: Colors.white,
                ),
              ),
            ),

            Positioned(
              bottom: screenHeight * 0.03,
              right: screenWidth * 0.1,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ProfilePage()),
                  );
                },
                child: Icon(
                  Icons.person_outlined,
                  size: isSmallScreen ? 28 : 32,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
