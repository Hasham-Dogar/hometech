// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import '../models/video_model.dart';
import '../utils/video_utils.dart';

/// Feed video item widget for inline scrollable video feed
class FeedVideoItem extends StatelessWidget {
  final VideoModel video;
  final VoidCallback onTap;

  const FeedVideoItem({super.key, required this.video, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildThumbnail(),
              const SizedBox(height: 8),
              _buildVideoInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              video.thumbnail,
              cacheWidth: 480,
              cacheHeight: 270,
              filterQuality: FilterQuality.low,
              gaplessPlayback: true,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey.shade300,
                child: const Center(
                  child: Icon(Icons.broken_image, color: Colors.black45),
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
        ),
        Positioned(
          right: 10,
          bottom: 10,
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(video.channelAvatar),
          radius: 16,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                video.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${video.channel} • ${video.views} views • ${video.published}',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.open_in_new),
          tooltip: 'Open in main player',
          onPressed: onTap,
        ),
      ],
    );
  }
}

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

/// Loading indicator for video feeds
class VideoFeedLoadingIndicator extends StatelessWidget {
  final String? message;

  const VideoFeedLoadingIndicator({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(message!, style: const TextStyle(color: Colors.black54)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Empty feed placeholder
class EmptyFeedPlaceholder extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onRetry;

  const EmptyFeedPlaceholder({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.video_library_outlined,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Colors.black38),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
