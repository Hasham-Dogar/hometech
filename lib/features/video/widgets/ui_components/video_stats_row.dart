import 'package:flutter/material.dart';
import '../../models/video_model.dart';

/// Video stats row showing views and publish date
class VideoStatsRow extends StatelessWidget {
  final VideoModel video;

  const VideoStatsRow({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '${video.views} views',
          style: const TextStyle(color: Colors.black54, fontSize: 13),
        ),
        const SizedBox(width: 8),
        const Text('•', style: TextStyle(color: Colors.black45)),
        const SizedBox(width: 8),
        Text(
          video.published,
          style: const TextStyle(color: Colors.black54, fontSize: 13),
        ),
      ],
    );
  }
}
