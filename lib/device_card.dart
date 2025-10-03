import 'package:flutter/material.dart';

class DeviceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool status;
  final Function(bool) onChanged;

  const DeviceCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.status,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color.fromARGB(255, 221, 41, 206), Color(0xFFB16CEA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, size: 32, color: const Color.fromARGB(255, 255, 133, 77)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 255, 251, 251),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: status,
            onChanged: onChanged,
            activeThumbColor: Colors.deepPurpleAccent,
          ),
        ],
      ),
    );
  }
}
