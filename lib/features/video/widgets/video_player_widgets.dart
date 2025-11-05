import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:chewie/chewie.dart';
import '../models/video_model.dart';
import '../config/video_config.dart';

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
          _MiniControlButton(
            icon: Icons.picture_in_picture_alt_outlined,
            tooltip: 'Minimize',
            onTap: onMinimize,
          ),
          const SizedBox(width: 6),
          _MiniControlButton(
            icon: Icons.close,
            tooltip: 'Close',
            onTap: onClose,
          ),
        ],
      ),
    );
  }
}

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
                    _MiniControlButton(
                      icon: Icons.open_in_full,
                      tooltip: 'Expand',
                      onTap: onExpand,
                    ),
                    const SizedBox(width: 6),
                    _MiniControlButton(
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

/// Next video autoplay countdown overlay
class NextVideoOverlay extends StatelessWidget {
  final VideoModel? nextVideo;
  final int secondsRemaining;
  final VoidCallback onPlayNow;
  final VoidCallback onCancel;

  const NextVideoOverlay({
    super.key,
    this.nextVideo,
    required this.secondsRemaining,
    required this.onPlayNow,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final nextTitle = nextVideo?.title ?? 'Next video';

    return Positioned(
      right: 12,
      bottom: 12,
      child: Material(
        color: Colors.white,
        elevation: 6,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 260,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.play_circle_fill, color: Colors.redAccent),
                  const SizedBox(width: 8),
                  Text(
                    'Up next in $secondsRemaining s',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                nextTitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: onCancel, child: const Text('Cancel')),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: onPlayNow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    child: const Text('Play now'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Empty player placeholder when no video is selected
class EmptyPlayerPlaceholder extends StatelessWidget {
  final bool isLoading;

  const EmptyPlayerPlaceholder({super.key, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black12,
      child: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : const Icon(
                Icons.play_circle_fill,
                size: 72,
                color: Colors.white70,
              ),
      ),
    );
  }
}

/// Mini control button used in player overlays
class _MiniControlButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _MiniControlButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 18, color: Colors.white),
        ),
      ),
    );
  }
}
