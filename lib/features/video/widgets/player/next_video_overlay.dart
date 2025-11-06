import 'package:flutter/material.dart';
import '../../models/video_model.dart';

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
