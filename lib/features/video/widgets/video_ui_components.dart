import 'package:flutter/material.dart';
import '../models/video_model.dart';

/// Action chips row (Like, Share, Download, etc.)
class ActionChips extends StatelessWidget {
  const ActionChips({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip(Icons.thumb_up_alt_outlined, 'Like'),
          const SizedBox(width: 16),
          _buildChip(Icons.share_outlined, 'Share'),
          const SizedBox(width: 16),
          _buildChip(Icons.download_outlined, 'Download'),
          const SizedBox(width: 16),
          _buildChip(Icons.cut_outlined, 'Clip'),
          const SizedBox(width: 16),
          _buildChip(Icons.library_add_outlined, 'Save'),
        ],
      ),
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.grey.shade200,
          child: Icon(icon, color: Colors.black87),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

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

/// Comments preview section
class CommentsPreview extends StatelessWidget {
  final VoidCallback? onTap;

  const CommentsPreview({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const CircleAvatar(
        radius: 16,
        backgroundImage: NetworkImage('https://i.pravatar.cc/48?img=12'),
      ),
      title: const Text(
        'Comments',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: const Text('"Great video! Love the content."'),
      trailing: const Icon(Icons.keyboard_arrow_right),
      onTap: onTap ?? () {},
    );
  }
}

/// Up next header with autoplay toggle
class UpNextHeader extends StatelessWidget {
  final bool autoplayEnabled;
  final ValueChanged<bool>? onAutoplayChanged;

  const UpNextHeader({
    super.key,
    required this.autoplayEnabled,
    this.onAutoplayChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Up next',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
        ),
        Row(
          children: [
            const Text('Autoplay', style: TextStyle(color: Colors.black54)),
            const SizedBox(width: 8),
            Switch(value: autoplayEnabled, onChanged: onAutoplayChanged),
          ],
        ),
      ],
    );
  }
}

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

/// Search field widget for video search
class VideoSearchField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final bool autofocus;
  final String hintText;

  const VideoSearchField({
    super.key,
    required this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.autofocus = false,
    this.hintText = 'Search videos',
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  controller.clear();
                  onClear?.call();
                },
              )
            : null,
        isDense: true,
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onChanged: onChanged,
      onSubmitted: onSubmitted,
    );
  }
}

/// App bar title with YouTube branding
class VideoAppBarTitle extends StatelessWidget {
  final bool showSearch;
  final TextEditingController? searchController;
  final FocusNode? searchFocusNode;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onSearchSubmitted;

  const VideoAppBarTitle({
    super.key,
    this.showSearch = false,
    this.searchController,
    this.searchFocusNode,
    this.onSearchChanged,
    this.onSearchSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    if (showSearch && searchController != null) {
      return TextField(
        controller: searchController,
        focusNode: searchFocusNode,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Search videos',
          border: InputBorder.none,
        ),
        onChanged: onSearchChanged,
        onSubmitted: onSearchSubmitted,
      );
    }

    return Row(
      children: const [
        SizedBox(width: 8),
        Icon(Icons.play_circle_fill, color: Colors.redAccent, size: 28),
        SizedBox(width: 6),
        Text(
          'YouTube',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}

/// Configuration status banner
class ConfigurationBanner extends StatelessWidget {
  final String message;
  final Color? backgroundColor;
  final VoidCallback? onDismiss;

  const ConfigurationBanner({
    super.key,
    required this.message,
    this.backgroundColor,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: backgroundColor ?? Colors.orange.shade100,
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 20, color: Colors.orange.shade800),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 13, color: Colors.orange.shade800),
            ),
          ),
          if (onDismiss != null)
            IconButton(
              icon: Icon(Icons.close, size: 20, color: Colors.orange.shade800),
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
        ],
      ),
    );
  }
}

/// Loading progress indicator for video operations
class VideoLoadingIndicator extends StatelessWidget {
  final String? message;
  final double? progress;

  const VideoLoadingIndicator({super.key, this.message, this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (progress != null)
            LinearProgressIndicator(value: progress, minHeight: 2)
          else
            const LinearProgressIndicator(minHeight: 2),
          if (message != null) ...[
            const SizedBox(height: 8),
            Text(
              message!,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Error display widget for video operations
class VideoErrorDisplay extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onRetry;

  const VideoErrorDisplay({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.error_outline,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}
