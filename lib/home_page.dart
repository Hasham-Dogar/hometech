import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'dart:ui';
import 'services/weather_api.dart';
import 'device_card.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'room_detail_page.dart';
import 'thermostat_config_page.dart';
import 'smart_light_page.dart';
import 'smart_plug_page.dart';
import 'smart_tv_page.dart';
import 'air_conditioner_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

  Future<Position?> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      bool? result = await showDialog<bool>(
        context: context,
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
        await Geolocator.openLocationSettings();
        return null;
      } else {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Location Needed'),
            content: const Text(
              'You must enable location in settings to use this feature.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Geolocator.openLocationSettings();
                  Navigator.of(context).pop();
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );
        return null;
      }
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low,
    );
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
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Home",
                            style: TextStyle(
                              fontSize: isSmallScreen ? 24 : 28,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF22223B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Family members",
                            style: TextStyle(
                              fontSize: isSmallScreen ? 12 : 14,
                              color: const Color(0xFF9A9AB0),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          // Button to open pick-location map page
                          IconButton(
                            icon: const Icon(
                              Icons.map,
                              color: Color(0xFFB16CEA),
                            ),
                            tooltip: 'Pick location on map',
                            onPressed: () async {
                              final picked = await Navigator.pushNamed(
                                context,
                                '/pick-location',
                              );
                              if (picked != null && picked is LatLng) {
                                final latlon =
                                    '${picked.latitude},${picked.longitude}';
                                setState(() {
                                  _loadingWeather = true;
                                  _weatherError = null;
                                });
                                try {
                                  final data = await WeatherApi()
                                      .fetchCurrentWeather(latlon)
                                      .timeout(const Duration(seconds: 10));
                                  setState(() => _weather = data);
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
                                  if (mounted)
                                    setState(() => _loadingWeather = false);
                                }
                              }
                            },
                          ),
                          Row(
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ProfilePage(),
                                    ),
                                  );
                                },
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundImage: AssetImage("assets/1.jpeg"),
                                ),
                              ),
                              SizedBox(width: 4),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ProfilePage(),
                                    ),
                                  );
                                },
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundImage: AssetImage("assets/2.jpg"),
                                ),
                              ),
                              SizedBox(width: 4),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ProfilePage(),
                                    ),
                                  );
                                },
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundImage: AssetImage("assets/3.jpeg"),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: isSmallScreen ? 14 : 18),

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(isSmallScreen ? 14 : 18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFB16CEA),
                          Color(0xFFFF5E69),
                          Color(0xFFFF8A56),
                          Color(0xFFFFC86A),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_loadingWeather)
                          SizedBox(
                            height: isSmallScreen ? 80 : 100,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          )
                        else if (_weatherError != null)
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Weather error: $_weatherError',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isSmallScreen ? 12 : 14,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.refresh,
                                  color: Colors.white,
                                ),
                                onPressed: () => _loadWeatherUsingGps(),
                              ),
                            ],
                          )
                        else
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _weather?['location']?['name'] ??
                                          'Unknown',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isSmallScreen ? 14 : 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '${_weather?['current']?['temp_c'] ?? '--'}°',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isSmallScreen ? 28 : 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      _weather?['current']?['condition']?['text'] ??
                                          '',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isSmallScreen ? 12 : 14,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Feels like: ${_weather?['current']?['feelslike_c'] ?? '--'}°',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isSmallScreen ? 10 : 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Builder(
                                builder: (context) {
                                  final iconPath =
                                      _weather?['current']?['condition']?['icon']
                                          as String?;
                                  if (iconPath != null && iconPath.isNotEmpty) {
                                    final url = iconPath.startsWith('http')
                                        ? iconPath
                                        : 'https:$iconPath';
                                    return Image.network(
                                      url,
                                      width: isSmallScreen ? 40 : 56,
                                      height: isSmallScreen ? 40 : 56,
                                      errorBuilder: (_, __, ___) => Icon(
                                        Icons.cloud,
                                        color: Colors.white,
                                        size: isSmallScreen ? 40 : 48,
                                      ),
                                    );
                                  }
                                  return Icon(
                                    Icons.cloud,
                                    color: Colors.white,
                                    size: isSmallScreen ? 40 : 48,
                                  );
                                },
                              ),
                            ],
                          ),
                        const SizedBox(height: 8),
                        if (_forecast != null)
                          SizedBox(
                            height: 104,
                            child: _ForecastStrip(forecastJson: _forecast!),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 14 : 18),

                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDEDF7),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: _tabIndex == 0
                                  ? Colors.white
                                  : Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _tabIndex = 0;
                              });
                            },
                            child: Text(
                              'Room',
                              style: TextStyle(
                                color: _tabIndex == 0
                                    ? const Color(0xFF22223B)
                                    : const Color(0xFF9A9AB0),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: _tabIndex == 1
                                  ? Colors.white
                                  : Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _tabIndex = 1;
                              });
                            },
                            child: Text(
                              'Devices',
                              style: TextStyle(
                                color: _tabIndex == 1
                                    ? const Color(0xFF22223B)
                                    : const Color(0xFF9A9AB0),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 14 : 18),

                  // Content
                  Expanded(
                    child: _tabIndex == 0
                        ? GridView.builder(
                            physics: const BouncingScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 250,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 1.2,
                                ),
                            itemCount: rooms.length,
                            itemBuilder: (context, index) {
                              final room = rooms[index];
                              return GestureDetector(
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => RoomDetailPage2(
                                        roomName: room["title"],
                                        devices: devices
                                            .where(
                                              (d) =>
                                                  d["subtitle"] ==
                                                  room["title"],
                                            )
                                            .toList(),
                                      ),
                                    ),
                                  );
                                  if (mounted) setState(() {});
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 8,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ClipRect(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            child: Image.asset(
                                              room["image"],
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => const Icon(
                                                    Icons.error,
                                                    size: 50,
                                                  ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                room["title"],
                                                style: TextStyle(
                                                  fontSize: isSmallScreen
                                                      ? 12
                                                      : 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: const Color(
                                                    0xFF22223B,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 1),
                                              Text(
                                                room["devices"],
                                                style: TextStyle(
                                                  fontSize: isSmallScreen
                                                      ? 8
                                                      : 10,
                                                  color: const Color(
                                                    0xFF9A9AB0,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Row(
                                                children: [
                                                  Text(
                                                    room["status"]
                                                        ? "ON"
                                                        : "OFF",
                                                    style: TextStyle(
                                                      fontSize: isSmallScreen
                                                          ? 8
                                                          : 10,
                                                      color: room["status"]
                                                          ? const Color(
                                                              0xFFB16CEA,
                                                            )
                                                          : const Color(
                                                              0xFF9A9AB0,
                                                            ),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  Switch(
                                                    value: room["status"],
                                                    onChanged: (val) {
                                                      setState(() {
                                                        rooms[index]["status"] =
                                                            val;
                                                      });
                                                    },
                                                    activeThumbColor:
                                                        const Color(0xFFB16CEA),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                        : ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            itemCount: devices.length,
                            separatorBuilder: (context, _) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final device = devices[index];
                              Widget card = DeviceCard(
                                title: device["title"],
                                subtitle: device["subtitle"],
                                icon: device["icon"],
                                status: device["status"],
                                onChanged: (val) {
                                  setState(() {
                                    devices[index]["status"] = val;
                                    // Update the room status that contains this device.
                                    final roomTitle =
                                        devices[index]["subtitle"];
                                    final roomIndex = rooms.indexWhere(
                                      (r) => r["title"] == roomTitle,
                                    );
                                    if (roomIndex != -1) {
                                      // If any device in this room is ON, mark room ON.
                                      final anyOn = devices
                                          .where(
                                            (d) => d["subtitle"] == roomTitle,
                                          )
                                          .any((d) => d["status"] == true);
                                      rooms[roomIndex]["status"] = anyOn;
                                    }
                                  });
                                },
                              );
                              switch (device["title"]) {
                                case "Thermostat":
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ThermostatScreen(),
                                        ),
                                      );
                                    },
                                    child: card,
                                  );
                                case "Smart Light":
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => SmartLightPage(
                                            status: device["status"],
                                            onChanged: (val) {
                                              setState(() {
                                                devices[index]["status"] = val;
                                                final roomTitle =
                                                    devices[index]["subtitle"];
                                                final roomIndex = rooms
                                                    .indexWhere(
                                                      (r) =>
                                                          r["title"] ==
                                                          roomTitle,
                                                    );
                                                if (roomIndex != -1) {
                                                  final anyOn = devices
                                                      .where(
                                                        (d) =>
                                                            d["subtitle"] ==
                                                            roomTitle,
                                                      )
                                                      .any(
                                                        (d) =>
                                                            d["status"] == true,
                                                      );
                                                  rooms[roomIndex]["status"] =
                                                      anyOn;
                                                }
                                              });
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                    child: card,
                                  );
                                case "Smart Plug":
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => SmartPlugPage(
                                            status: device["status"],
                                            onChanged: (val) {
                                              setState(() {
                                                devices[index]["status"] = val;
                                                final roomTitle =
                                                    devices[index]["subtitle"];
                                                final roomIndex = rooms
                                                    .indexWhere(
                                                      (r) =>
                                                          r["title"] ==
                                                          roomTitle,
                                                    );
                                                if (roomIndex != -1) {
                                                  final anyOn = devices
                                                      .where(
                                                        (d) =>
                                                            d["subtitle"] ==
                                                            roomTitle,
                                                      )
                                                      .any(
                                                        (d) =>
                                                            d["status"] == true,
                                                      );
                                                  rooms[roomIndex]["status"] =
                                                      anyOn;
                                                }
                                              });
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                    child: card,
                                  );
                                case "Smart TV":
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => SmartTVPage(),
                                        ),
                                      );
                                    },
                                    child: card,
                                  );
                                case "Air Conditioner":
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => AirConditionerPage(
                                            initialTemp: 24.0,
                                            status: device["status"],
                                            onStatusChanged: (val) {
                                              setState(() {
                                                devices[index]["status"] = val;
                                                final roomTitle =
                                                    devices[index]["subtitle"];
                                                final roomIndex = rooms
                                                    .indexWhere(
                                                      (r) =>
                                                          r["title"] ==
                                                          roomTitle,
                                                    );
                                                if (roomIndex != -1) {
                                                  final anyOn = devices
                                                      .where(
                                                        (d) =>
                                                            d["subtitle"] ==
                                                            roomTitle,
                                                      )
                                                      .any(
                                                        (d) =>
                                                            d["status"] == true,
                                                      );
                                                  rooms[roomIndex]["status"] =
                                                      anyOn;
                                                }
                                              });
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                    child: card,
                                  );
                                default:
                                  return card;
                              }
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: (screenWidth - fabSize * 0.7) / 2,
            child: GlassmorphicContainer(
              width: fabSize * 0.7,
              height: fabSize * 0.7,
              borderRadius: fabSize,
              blur: 100,
              alignment: Alignment.center,
              border: 1,
              linearGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color.fromARGB(255, 248, 167, 215).withOpacity(0.2),
                  const Color.fromARGB(255, 248, 167, 215).withOpacity(0.05),
                ],
              ),
              borderGradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.5),
                  Colors.white.withOpacity(0.5),
                ],
              ),
              child: Container(
                margin: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return const LinearGradient(
                      colors: [Color(0xFF9C27B0), Color(0xFFE91E63)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.srcIn,
                  child: Icon(
                    Icons.mic_none_outlined,
                    color: Colors.white,
                    size: fabSize * 0.3,
                  ),
                ),
              ),
            ),
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

class _NavBarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF252A4A)
      ..style = PaintingStyle.fill;

    final topY = 20.0;
    final valleyY = size.height + 4;
    final leftFlatEnd = 0.12;
    final rightFlatStart = 0.88;
    final outerRadius = 24.0;
    final cpDepart = 0.18;
    final cpValley = 0.20; // Adjusted to fix overlapping

    final w = size.width;
    final h = size.height;

    final path = Path();
    path.moveTo(0, topY);

    path.lineTo(w * leftFlatEnd, topY);

    path.cubicTo(
      w * (leftFlatEnd + cpDepart),
      topY,
      w * (0.5 - cpValley),
      valleyY,
      w * 0.5,
      valleyY,
    );

    path.cubicTo(
      w * (0.5 + cpValley),
      valleyY,
      w * (rightFlatStart - cpDepart),
      topY,
      w * rightFlatStart,
      topY,
    );

    path.lineTo(w, topY);

    path.arcToPoint(
      Offset(w, h),
      radius: Radius.circular(outerRadius),
      clockwise: true,
    );

    path.lineTo(0, h);

    path.arcToPoint(
      Offset(0, topY),
      radius: Radius.circular(outerRadius),
      clockwise: true,
    );

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ForecastStrip extends StatelessWidget {
  final Map<String, dynamic> forecastJson;

  const _ForecastStrip({required this.forecastJson});

  @override
  Widget build(BuildContext context) {
    final days =
        (forecastJson['forecast']?['forecastday'] as List<dynamic>?) ?? [];
    if (days.isEmpty) return const SizedBox.shrink();

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      itemBuilder: (context, index) {
        final day = days[index] as Map<String, dynamic>;
        final date = day['date'] as String? ?? '';
        final dayInfo = day['day'] as Map<String, dynamic>? ?? {};
        final maxTemp = dayInfo['maxtemp_c']?.toString() ?? '--';
        final minTemp = dayInfo['mintemp_c']?.toString() ?? '--';
        final iconPath = dayInfo['condition']?['icon'] as String? ?? '';
        final iconUrl = iconPath.startsWith('http')
            ? iconPath
            : 'https:$iconPath';

        return Container(
          width: 120,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                date,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              const SizedBox(height: 6),
              Image.network(
                iconUrl,
                width: 36,
                height: 36,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.cloud, color: Colors.white),
              ),
              const SizedBox(height: 6),
              Text(
                '$maxTemp° / $minTemp°',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemCount: days.length,
    );
  }
}
