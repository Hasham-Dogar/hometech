import 'package:flutter/material.dart';
import '../../models/video_model.dart';

/// Video metadata widget for displaying title, channel, views, etc.
class VideoMetadata extends StatelessWidget {
  final VideoModel video;
  final int? maxTitleLines;
  final bool showChannelAvatar;
  final bool showViews;
  final bool showPublished;
  final TextStyle? titleStyle;
  final TextStyle? metaStyle;

  const VideoMetadata({
    super.key,
    required this.video,
    this.maxTitleLines = 2,
    this.showChannelAvatar = true,
    this.showViews = true,
    this.showPublished = true,
    this.titleStyle,
    this.metaStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showChannelAvatar) ...[
          CircleAvatar(
            backgroundImage: NetworkImage(video.channelAvatar),
            radius: 16,
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                video.title,
                maxLines: maxTitleLines,
                overflow: TextOverflow.ellipsis,
                style:
                    titleStyle ??
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                _buildMetaText(),
                style:
                    metaStyle ??
                    const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _buildMetaText() {
    final parts = <String>[video.channel];

    if (showViews) {
      parts.add('${video.views} views');
    }

    if (showPublished) {
      parts.add(video.published);
    }

    return parts.join(' • ');
  }
}
