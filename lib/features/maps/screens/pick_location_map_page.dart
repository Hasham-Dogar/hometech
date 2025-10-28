import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../weather/services/weather_api.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'location_history_map_page.dart';

class PickLocationMapPage extends StatefulWidget {
  const PickLocationMapPage({super.key});

  @override
  State<PickLocationMapPage> createState() => _PickLocationMapPageState();
}

class _PickLocationMapPageState extends State<PickLocationMapPage> {
  LatLng? selectedPoint;
  Map<String, dynamic>? weather;
  Map<String, dynamic>? forecast;
  bool loading = false;
  String? error;

  Future<void> _onTap(TapPosition tapPosition, LatLng latlng) async {
    print('Map tapped at: [32m$latlng[0m');
    setState(() {
      selectedPoint = latlng;
      weather = null;
      forecast = null;
      loading = true;
      error = null;
    });
    try {
      final latlon = '${latlng.latitude},${latlng.longitude}';
      print('Fetching weather for: $latlon');
      final w = await WeatherApi().fetchCurrentWeather(latlon);
      print('Weather response: $w');
      final f = await WeatherApi().fetchForecast(latlon, days: 3);
      print('Forecast response: $f');
      setState(() {
        weather = w;
        forecast = f;
        loading = false;
      });
    } catch (e, st) {
      print('Error fetching weather: $e\n$st');
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  Future<void> _saveLocationToFirebase(LatLng point) async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? 'anonymous';
    final now = DateTime.now();
    final dateStr =
        "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final ref = FirebaseDatabase.instance.ref(
      'user_locations/$userId/$dateStr',
    );
    print('[Firebase] Writing location for userId=$userId at path=${ref.path}');
    final data = {
      'latitude': point.latitude,
      'longitude': point.longitude,
      'timestamp': now.toIso8601String(),
    };
    print('[Firebase] Data: $data');
    await ref.push().set(data);
  }

  @override
  Widget build(BuildContext context) {
    print(
      '[build] selectedPoint=$selectedPoint, weather=$weather, loading=$loading, error=$error',
    );
    final isConfirmEnabled =
        selectedPoint != null && weather != null && !loading;
    print(
      '[ConfirmButton] enabled=$isConfirmEnabled selectedPoint=$selectedPoint weather=$weather loading=$loading',
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick a location on map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Show Location History',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const LocationHistoryMapPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(31.5, 74.3),
                initialZoom: 10,
                onTap: _onTap,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.weather_app',
                ),
                if (selectedPoint != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: selectedPoint!,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          if (loading)
            const Padding(
              padding: EdgeInsets.all(12),
              child: CircularProgressIndicator(),
            ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'Error: $error',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          if (weather != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    'Weather: ${weather!['current']?['temp_c']}°C, '
                    '${weather!['current']?['condition']?['text']}',
                  ),
                  if (forecast != null)
                    SizedBox(
                      height: 120,
                      child: _ForecastStrip(forecastJson: forecast!),
                    ),
                ],
              ),
            ),
          // Confirm button
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text('Confirm Location'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                minimumSize: const Size(180, 44),
              ),
              onPressed: isConfirmEnabled
                  ? () async {
                      print(
                        '[ConfirmButton] pressed with selectedPoint=$selectedPoint weather=$weather',
                      );
                      try {
                        await _saveLocationToFirebase(selectedPoint!);
                        print(
                          '[ConfirmButton] Firebase write complete, popping with $selectedPoint',
                        );
                        if (!mounted) return;
                        Navigator.of(context).pop(selectedPoint);
                        print('[ConfirmButton] Navigator.pop called');
                      } catch (e, st) {
                        print('[ConfirmButton] ERROR during confirm: $e\n$st');
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error saving location: $e'),
                            ),
                          );
                        }
                      }
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

// Reuse the forecast strip widget from home_page.dart
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
                style: const TextStyle(color: Colors.black, fontSize: 12),
              ),
              const SizedBox(height: 6),
              Image.network(
                iconUrl,
                width: 36,
                height: 36,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.cloud, color: Colors.black),
              ),
              const SizedBox(height: 6),
              Text(
                '$maxTemp° / $minTemp°',
                style: const TextStyle(color: Colors.black, fontSize: 12),
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
