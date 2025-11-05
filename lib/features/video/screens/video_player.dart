import 'package:flutter/material.dart';

/// This file previously contained Cloudinary video upload functionality.
/// All Cloudinary-related code has been removed from this project.
/// If you need video upload functionality, please implement an alternative solution.

class YouTubeStyleUploader extends StatefulWidget {
  const YouTubeStyleUploader({super.key});

  @override
  State<YouTubeStyleUploader> createState() => _YouTubeStyleUploaderState();
}

class _YouTubeStyleUploaderState extends State<YouTubeStyleUploader> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          children: [
            Icon(Icons.ondemand_video, color: Colors.redAccent),
            const SizedBox(width: 8),
            const Text('Video Uploader', style: TextStyle(color: Colors.white)),
          ],
        ),
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off, size: 80, color: Colors.white54),
              const SizedBox(height: 24),
              Text(
                'Upload Feature Unavailable',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Cloudinary integration has been removed from this application.\n\nIf you need video upload functionality, please implement an alternative video hosting solution.',
                style: TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
