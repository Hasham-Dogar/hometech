import 'package:flutter/material.dart';

class RoomCard extends StatelessWidget {
  final String title;
  final String devices;
  final IconData icon;
  final VoidCallback? onTap;

  const RoomCard({
    super.key,
    required this.title,
    required this.devices,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 75, 75, 165),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: Colors.deepPurpleAccent),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(devices, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
