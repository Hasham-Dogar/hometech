import 'package:flutter_dotenv/flutter_dotenv.dart';

class VideoConfig {
  // API Keys (loaded from .env)
  static String? _ytApiKey;

  // App constants
  static const int autoplayCountdownSeconds = 5;
  static const int maxResultsPerPage = 20;
  static const String defaultRegionCode = 'US';
  static const int scrollLoadThreshold = 200;
  static const int miniPlayerWidth = 200;
  static const double miniPlayerHeight = 112.5; // 16:9 aspect ratio

  // Getters for API keys
  static String? get ytApiKey => _ytApiKey;

  /// Load environment variables from .env file
  static void loadEnvVariables() {
    try {
      final ytKey = dotenv.env['YOUTUBE_API_KEY'];
      _ytApiKey = ytKey?.trim();
    } catch (e) {
      // Handle environment loading errors gracefully
      print('Warning: Could not load environment variables: $e');
    }
  }

  /// Check if YouTube API is properly configured
  static bool get isYouTubeConfigured =>
      _ytApiKey != null && _ytApiKey!.isNotEmpty;

  /// Get YouTube API base URL
  static const String youtubeApiBaseUrl =
      'https://www.googleapis.com/youtube/v3';

  /// Get configuration status message
  static String getConfigurationStatus() {
    final List<String> issues = [];

    if (!isYouTubeConfigured) {
      issues.add('YouTube API key missing');
    }

    if (issues.isEmpty) {
      return 'All services configured';
    } else {
      return 'Configuration issues: ${issues.join(', ')}';
    }
  }
}
