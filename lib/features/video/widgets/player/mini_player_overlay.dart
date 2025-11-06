import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:chewie/chewie.dart';
import '../../models/video_model.dart';
import '../../config/video_config.dart';
import 'mini_control_button.dart';

/// Mini player overlay widget
class MiniPlayerOverlay extends StatelessWidget {
  final VideoModel video;
  final YoutubePlayerController? youtubeController;
  final ChewieController? chewieController;
  final VoidCallback onExpand;
  final VoidCallback onClose;

  const MiniPlayerOverlay({
    super.key,
    required this.video,
    this.youtubeController,
    this.chewieController,
    required this.onExpand,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    Widget playerContent;

    if (video.type == 'youtube' && youtubeController != null) {
      playerContent = YoutubePlayer(
        key: ValueKey('mini-yt-${video.videoId}'),
        controller: youtubeController!,
        showVideoProgressIndicator: true,
      );
    } else {
      playerContent = Container(
        color: Colors.black,
        child: const Center(
          child: Icon(Icons.play_circle_fill, color: Colors.white, size: 32),
        ),
      );
    }

    return Positioned(
      right: 12,
      bottom: 12,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: Container(
          width: VideoConfig.miniPlayerWidth.toDouble(),
          height: VideoConfig.miniPlayerHeight,
          color: Colors.black,
          child: Stack(
            fit: StackFit.expand,
            children: [
              playerContent,
              Positioned(
                right: 6,
                top: 6,
                child: Row(
                  children: [
                    MiniControlButton(
                      icon: Icons.open_in_full,
                      tooltip: 'Expand',
                      onTap: onExpand,
                    ),
                    const SizedBox(width: 6),
                    MiniControlButton(
                      icon: Icons.close,
                      tooltip: 'Close',
                      onTap: onClose,
                    ),
                  ],
                ),
              ),
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(onTap: onExpand),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
