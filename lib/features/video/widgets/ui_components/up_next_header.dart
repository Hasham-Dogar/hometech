import 'package:flutter/material.dart';

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
