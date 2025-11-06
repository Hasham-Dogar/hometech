import 'package:flutter/material.dart';
import '../../models/video_model.dart';

/// Channel information row with avatar, name, and subscribe button
class ChannelRow extends StatelessWidget {
  final VideoModel video;
  final VoidCallback? onSubscribe;

  const ChannelRow({super.key, required this.video, this.onSubscribe});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(video.channelAvatar),
          radius: 18,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                video.channel,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const Text(
                '1.2M subscribers', // This could be made dynamic
                style: TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ],
          ),
        ),
        TextButton.icon(
          onPressed: onSubscribe ?? () {},
          icon: const Icon(
            Icons.notifications_active_outlined,
            color: Colors.black87,
          ),
          label: const Text(
            'Subscribe',
            style: TextStyle(color: Colors.black87),
          ),
          style: TextButton.styleFrom(
            backgroundColor: Colors.grey.shade200,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }
}
