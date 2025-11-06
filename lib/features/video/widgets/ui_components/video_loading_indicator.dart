import 'package:flutter/material.dart';

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
