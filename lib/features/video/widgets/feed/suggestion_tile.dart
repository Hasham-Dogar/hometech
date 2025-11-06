import 'package:flutter/material.dart';
import '../../models/video_model.dart';

/// Suggestion tile widget for showing related videos
class SuggestionTile extends StatelessWidget {
  final VideoModel video;
  final VoidCallback onTap;

  const SuggestionTile({super.key, required this.video, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildThumbnail(),
            const SizedBox(width: 12),
            Expanded(child: _buildVideoInfo()),
            const SizedBox(width: 8),
            const Icon(Icons.more_vert, color: Colors.black54),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            video.thumbnail,
            width: 168,
            height: 94,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 168,
              height: 94,
              color: Colors.grey.shade300,
              child: const Icon(Icons.broken_image, color: Colors.black45),
            ),
          ),
        ),
        Positioned(
          right: 6,
          bottom: 6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.85),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              video.duration,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          video.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          video.channel,
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
        const SizedBox(height: 2),
        Text(
          '${video.views} views • ${video.published}',
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }
}
