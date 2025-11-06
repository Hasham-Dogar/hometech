import 'package:flutter/material.dart';

/// Comments preview section
class CommentsPreview extends StatelessWidget {
  final VoidCallback? onTap;

  const CommentsPreview({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const CircleAvatar(
        radius: 16,
        backgroundImage: NetworkImage('https://i.pravatar.cc/48?img=12'),
      ),
      title: const Text(
        'Comments',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: const Text('"Great video! Love the content."'),
      trailing: const Icon(Icons.keyboard_arrow_right),
      onTap: onTap ?? () {},
    );
  }
}
