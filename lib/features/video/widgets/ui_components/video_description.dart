import 'package:flutter/material.dart';
import '../../models/video_model.dart';

/// Expandable video description widget
class VideoDescription extends StatefulWidget {
  final VideoModel video;
  final bool? initialExpanded;

  const VideoDescription({
    super.key,
    required this.video,
    this.initialExpanded = false,
  });

  @override
  State<VideoDescription> createState() => _VideoDescriptionState();
}

class _VideoDescriptionState extends State<VideoDescription> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initialExpanded ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final description = widget.video.description;

    if (description.isEmpty) {
      return const SizedBox.shrink();
    }

    return InkWell(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              description,
              maxLines: _isExpanded ? null : 2,
              overflow: _isExpanded
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 6),
            Text(
              _isExpanded ? 'Show less' : 'Show more',
              style: const TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
