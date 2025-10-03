import 'package:flutter/material.dart';

class AddProfilePage extends StatelessWidget {
  const AddProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Profile'),
        backgroundColor: const Color(0xFF252A4A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF5F6FA),
      body: Center(
        child: Text(
          'Add Profile Page (Coming Soon)',
          style: TextStyle(
            fontSize: 20,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
