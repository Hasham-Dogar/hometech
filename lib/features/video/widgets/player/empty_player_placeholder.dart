import 'package:flutter/material.dart';

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
