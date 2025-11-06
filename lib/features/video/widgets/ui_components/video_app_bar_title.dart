import 'package:flutter/material.dart';

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
