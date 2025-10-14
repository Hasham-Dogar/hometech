import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LocationHistoryMapPage extends StatefulWidget {
  const LocationHistoryMapPage({super.key});

  @override
  State<LocationHistoryMapPage> createState() => _LocationHistoryMapPageState();
}

class _LocationHistoryMapPageState extends State<LocationHistoryMapPage> {
  String? selectedDate;
  List<String> availableDates = [];
  List<LatLng> locations = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchAvailableDates();
  }

  Future<void> _fetchAvailableDates() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid ?? 'anonymous';
      final ref = FirebaseDatabase.instance.ref('user_locations/$userId');
      final snap = await ref.get();
      if (snap.exists) {
        final keys = snap.children
            .map((c) => c.key)
            .whereType<String>()
            .toList();
        keys.sort((a, b) => b.compareTo(a)); // newest first
        setState(() {
          availableDates = keys;
        });
      } else {
        setState(() {
          availableDates = [];
        });
      }
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _fetchLocationsForDate(String date) async {
    setState(() {
      loading = true;
      error = null;
      locations = [];
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid ?? 'anonymous';
      final ref = FirebaseDatabase.instance.ref('user_locations/$userId/$date');
      final snap = await ref.get();
      if (snap.exists) {
        final locs = <LatLng>[];
        for (final c in snap.children) {
          final data = c.value as Map?;
          if (data != null &&
              data['latitude'] != null &&
              data['longitude'] != null) {
            locs.add(
              LatLng(
                (data['latitude'] as num).toDouble(),
                (data['longitude'] as num).toDouble(),
              ),
            );
          }
        }
        setState(() {
          locations = locs;
        });
      } else {
        setState(() {
          locations = [];
        });
      }
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Location History')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text('Error: $error'))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton<String>(
                    value: selectedDate,
                    hint: const Text('Select a date'),
                    items: availableDates
                        .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                        .toList(),
                    onChanged: (d) {
                      setState(() {
                        selectedDate = d;
                      });
                      if (d != null) _fetchLocationsForDate(d);
                    },
                  ),
                ),
                Expanded(
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: locations.isNotEmpty
                          ? locations.first
                          : LatLng(31.5, 74.3),
                      initialZoom: 10,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.weather_app',
                      ),
                      if (locations.isNotEmpty)
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: locations,
                              strokeWidth: 4.0,
                              color: Colors.blueAccent,
                            ),
                          ],
                        ),
                      if (locations.isNotEmpty)
                        MarkerLayer(
                          markers: locations
                              .map(
                                (point) => Marker(
                                  point: point,
                                  width: 40,
                                  height: 40,
                                  child: const Icon(
                                    Icons.location_pin,
                                    color: Colors.blue,
                                    size: 40,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
