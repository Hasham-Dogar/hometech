import 'package:flutter/material.dart';

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
