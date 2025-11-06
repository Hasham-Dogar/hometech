import 'package:flutter/material.dart';
import '../../models/video_model.dart';

/// Video thumbnail widget with play overlay
class VideoThumbnail extends StatelessWidget {
  final VideoModel video;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final bool showDuration;
  final bool showPlayOverlay;

  const VideoThumbnail({
    super.key,
    required this.video,
    this.width,
    this.height,
    this.onTap,
    this.showDuration = true,
    this.showPlayOverlay = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget thumbnail = ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        video.thumbnail,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: width,
          height: height,
          color: Colors.grey.shade300,
          child: Icon(
            Icons.broken_image,
            color: Colors.black45,
            size: (width != null && width! < 100) ? 16 : 24,
          ),
        ),
      ),
    );

    if (!showPlayOverlay && !showDuration) {
      return onTap != null
          ? InkWell(onTap: onTap, child: thumbnail)
          : thumbnail;
    }

    return Stack(
      children: [
        thumbnail,
        if (showPlayOverlay)
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    padding: EdgeInsets.all(
                      (width != null && width! < 100) ? 4 : 8,
                    ),
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: (width != null && width! < 100) ? 16 : 32,
                    ),
                  ),
                ),
              ),
            ),
          ),
        if (showDuration)
          Positioned(
            right: 6,
            bottom: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.85),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                video.duration,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: (width != null && width! < 100) ? 10 : 12,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
