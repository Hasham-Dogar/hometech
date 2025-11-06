import 'package:flutter/material.dart';

/// Action chips row (Like, Share, Download, etc.)
class ActionChips extends StatelessWidget {
  const ActionChips({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip(Icons.thumb_up_alt_outlined, 'Like'),
          const SizedBox(width: 16),
          _buildChip(Icons.share_outlined, 'Share'),
          const SizedBox(width: 16),
          _buildChip(Icons.download_outlined, 'Download'),
          const SizedBox(width: 16),
          _buildChip(Icons.cut_outlined, 'Clip'),
          const SizedBox(width: 16),
          _buildChip(Icons.library_add_outlined, 'Save'),
        ],
      ),
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.grey.shade200,
          child: Icon(icon, color: Colors.black87),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
