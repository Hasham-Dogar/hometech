import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:chewie/chewie.dart';
import '../../models/video_model.dart';
import 'mini_control_button.dart';

/// Main video player widget that handles YouTube videos
class CustomVideoPlayer extends StatelessWidget {
  final VideoModel video;
  final YoutubePlayerController? youtubeController;
  final ChewieController? chewieController;
  final VoidCallback onMinimize;
  final VoidCallback onClose;

  const CustomVideoPlayer({
    super.key,
    required this.video,
    this.youtubeController,
    this.chewieController,
    required this.onMinimize,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    if (video.type == 'youtube' && youtubeController != null) {
      return _buildYouTubePlayer();
    } else {
      return _buildPlaceholderPlayer();
    }
  }

  Widget _buildYouTubePlayer() {
    return Stack(
      fit: StackFit.expand,
      children: [
        YoutubePlayer(
          key: ValueKey('yt-${video.videoId}'),
          controller: youtubeController!,
          showVideoProgressIndicator: true,
        ),
        _buildPlayerControls(),
      ],
    );
  }

  Widget _buildPlaceholderPlayer() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          video.thumbnail,
          cacheWidth: 480,
          cacheHeight: 270,
          filterQuality: FilterQuality.low,
          gaplessPlayback: true,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: Colors.black12,
            child: const Center(
              child: Icon(Icons.image_not_supported, color: Colors.white70),
            ),
          ),
        ),
        Container(color: Colors.black.withOpacity(0.2)),
        const Center(
          child: Icon(Icons.play_circle_fill, size: 72, color: Colors.white),
        ),
        _buildPlayerControls(),
      ],
    );
  }

  Widget _buildPlayerControls() {
    return Positioned(
      right: 6,
      top: 6,
      child: Row(
        children: [
          MiniControlButton(
            icon: Icons.picture_in_picture_alt_outlined,
            tooltip: 'Minimize',
            onTap: onMinimize,
          ),
          const SizedBox(width: 6),
          MiniControlButton(
            icon: Icons.close,
            tooltip: 'Close',
            onTap: onClose,
          ),
        ],
      ),
    );
  }
}
