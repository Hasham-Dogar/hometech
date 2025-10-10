import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'services/weather_api.dart';

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
    setState(() {
      selectedPoint = latlng;
      weather = null;
      forecast = null;
      loading = true;
      error = null;
    });
    try {
      final latlon = '${latlng.latitude},${latlng.longitude}';
      final w = await WeatherApi().fetchCurrentWeather(latlon);
      final f = await WeatherApi().fetchForecast(latlon, days: 3);
      setState(() {
        weather = w;
        forecast = f;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pick a location on map')),
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
              onPressed: (selectedPoint != null && weather != null && !loading)
                  ? () {
                      // Return the selected point to the caller
                      Navigator.of(context).pop(selectedPoint);
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
