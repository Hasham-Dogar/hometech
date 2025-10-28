import 'package:flutter_dotenv/flutter_dotenv.dart';

class VideoConfig {
  // Cloudinary configuration
  static String cloudName = 'djipdnpai';
  static String folderPrefix = 'videos';
  
  // API Keys (loaded from .env)
  static String? _apiKey;
  static String? _apiSecret;
  static String? _ytApiKey;
  
  // App constants
  static const int autoplayCountdownSeconds = 5;
  static const int maxResultsPerPage = 20;
  static const String defaultRegionCode = 'US';
  static const int scrollLoadThreshold = 200;
  static const int miniPlayerWidth = 200;
  static const double miniPlayerHeight = 112.5; // 16:9 aspect ratio
  
  // Quality options for Cloudinary
  static const List<int?> qualityOptions = [null, 360, 480, 720, 1080];
  static const Map<int?, String> qualityLabels = {
    null: 'Auto',
    360: '360p',
    480: '480p',
    720: '720p',
    1080: '1080p',
  };
  
  // Getters for API keys
  static String? get apiKey => _apiKey;
  static String? get apiSecret => _apiSecret;
  static String? get ytApiKey => _ytApiKey;
  
  /// Load environment variables from .env file
  static void loadEnvVariables() {
    try {
      final envCloud = dotenv.env['CLOUDINARY_CLOUD_NAME'];
      final k = dotenv.env['CLOUDINARY_API_KEY'];
      final s = dotenv.env['CLOUDINARY_API_SECRET'];
      final folder = dotenv.env['CLOUDINARY_FOLDER_PREFIX'];
      final ytKey = dotenv.env['YOUTUBE_API_KEY'];
      
      if (envCloud != null && envCloud.isNotEmpty) {
        cloudName = envCloud;
      }
      if (folder != null && folder.isNotEmpty) {
        folderPrefix = folder;
      }
      
      _apiKey = k?.trim();
      _apiSecret = s?.trim();
      _ytApiKey = ytKey?.trim();
    } catch (e) {
      // Handle environment loading errors gracefully
      print('Warning: Could not load environment variables: $e');
    }
  }
  
  /// Check if Cloudinary is properly configured
  static bool get isCloudinaryConfigured => 
      _apiKey != null && _apiSecret != null && 
      _apiKey!.isNotEmpty && _apiSecret!.isNotEmpty;
  
  /// Check if YouTube API is properly configured
  static bool get isYouTubeConfigured => 
      _ytApiKey != null && _ytApiKey!.isNotEmpty;
  
  /// Get Cloudinary base URL for resources
  static String get cloudinaryBaseUrl => 
      'https://res.cloudinary.com/$cloudName';
  
  /// Get Cloudinary API URL
  static String get cloudinaryApiUrl => 
      'https://api.cloudinary.com/v1_1/$cloudName';
  
  /// Get YouTube API base URL
  static const String youtubeApiBaseUrl = 'https://www.googleapis.com/youtube/v3';
  
  /// Generate Cloudinary thumbnail URL
  static String generateThumbnailUrl(String publicId, {
    int width = 320,
    int height = 180,
    String crop = 'fill',
    int second = 1,
  }) {
    return '$cloudinaryBaseUrl/video/upload/so_$second,w_$width,h_$height,c_$crop/$publicId.jpg';
  }
  
  /// Generate Cloudinary video URL with quality
  static String generateVideoUrl(String publicId, {int? height}) {
    if (height != null) {
      return '$cloudinaryBaseUrl/video/upload/c_limit,ar_16:9,h_$height,vc_h264/$publicId.mp4';
    }
    return '$cloudinaryBaseUrl/video/upload/$publicId.mp4';
  }
  
  /// Generate channel avatar URL
  static String generateChannelAvatarUrl(String channelName, {
    int size = 88,
    String? cloudinaryPublicId,
  }) {
    if (cloudinaryPublicId != null) {
      return '$cloudinaryBaseUrl/image/upload/w_$size,h_$size,c_fill/$cloudinaryPublicId';
    }
    return 'https://i.pravatar.cc/$size?u=$channelName';
  }
  
  /// Get configuration status message
  static String getConfigurationStatus() {
    final List<String> issues = [];
    
    if (!isCloudinaryConfigured) {
      issues.add('Cloudinary API keys missing');
    }
    
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