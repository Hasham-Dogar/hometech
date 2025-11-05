import 'package:shared_preferences/shared_preferences.dart';
import '../models/video_model.dart';

class VideoUtils {
  // Preference keys
  static const String _autoplayPrefKey = 'yt_autoplay_next';

  /// Load autoplay preference from SharedPreferences
  static Future<bool> loadAutoplayPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_autoplayPrefKey) ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Save autoplay preference to SharedPreferences
  static Future<void> saveAutoplayPreference(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_autoplayPrefKey, value);
    } catch (_) {
      // Handle error silently
    }
  }

  /// Get next playable video index from a list
  static int? getNextPlayableIndex(
    List<VideoModel> videoList,
    int currentIndex,
  ) {
    for (int i = 1; i <= videoList.length; i++) {
      final idx = (currentIndex + i) % videoList.length;
      final type = videoList[idx].type;
      if (type == 'youtube') {
        return idx;
      }
    }
    return null;
  }

  /// Filter videos based on search query
  static List<VideoModel> filterVideos(
    List<VideoModel> videos,
    String query, {
    int? excludeIndex,
  }) {
    final q = query.toLowerCase().trim();
    return videos
        .asMap()
        .entries
        .where((entry) => excludeIndex == null || entry.key != excludeIndex)
        .map((entry) => entry.value)
        .where((video) {
          if (q.isEmpty) return true;
          final title = video.title.toLowerCase();
          final channel = video.channel.toLowerCase();
          return title.contains(q) || channel.contains(q);
        })
        .toList();
  }

  /// Filter only YouTube videos for feed display
  static List<VideoModel> getYouTubeVideos(List<VideoModel> videos) {
    return videos.where((v) => v.type == 'youtube').toList();
  }

  /// Check if a video is playable (YouTube only)
  static bool isVideoPlayable(VideoModel video) {
    return video.type == 'youtube';
  }

  /// Generate a user-friendly error message for API failures
  static String getApiErrorMessage(String service, dynamic error) {
    final errorStr = error.toString();

    if (errorStr.contains('403') || errorStr.contains('401')) {
      return '$service API key is invalid or expired';
    }

    if (errorStr.contains('404')) {
      return '$service resource not found';
    }

    if (errorStr.contains('429')) {
      return '$service API quota exceeded. Please try again later';
    }

    if (errorStr.contains('NetworkException') ||
        errorStr.contains('SocketException')) {
      return 'Network connection error. Please check your internet connection';
    }

    return '$service request failed: $errorStr';
  }

  /// Convert a list of video maps to VideoModel list
  static List<VideoModel> mapListToVideoModels(
    List<Map<String, dynamic>> videoMaps,
  ) {
    return videoMaps.map((map) {
      final type = map['type']?.toString() ?? '';
      if (type == 'youtube') {
        return VideoModel.fromYoutubeJson(map);
      } else {
        // Handle legacy format or create from map directly
        return VideoModel(
          type: type,
          videoId: map['videoId']?.toString() ?? '',
          title: map['title']?.toString() ?? '',
          description: map['description']?.toString() ?? '',
          thumbnail: map['thumbnail']?.toString() ?? '',
          channel: map['channel']?.toString() ?? '',
          views: map['views']?.toString() ?? '',
          duration: map['duration']?.toString() ?? '',
          channelAvatar: map['channelAvatar']?.toString() ?? '',
          published: map['published']?.toString() ?? '',
        );
      }
    }).toList();
  }

  /// Convert VideoModel list to legacy map format (for backward compatibility)
  static List<Map<String, dynamic>> videoModelsToMapList(
    List<VideoModel> videos,
  ) {
    return videos.map((video) => video.toJson()).toList();
  }

  /// Validate YouTube video ID format
  static bool isValidYouTubeVideoId(String? videoId) {
    if (videoId == null || videoId.isEmpty) return false;
    final regex = RegExp(r'^[a-zA-Z0-9_-]{11}$');
    return regex.hasMatch(videoId);
  }

  /// Generate a fallback thumbnail URL if the original fails
  static String getFallbackThumbnail(VideoModel video) {
    if (video.type == 'youtube') {
      return 'https://img.youtube.com/vi/${video.videoId}/0.jpg';
    }
    return 'https://via.placeholder.com/320x180/cccccc/666666?text=No+Thumbnail';
  }

  /// Debounce function for search input
  static void debounce(
    Function() function,
    Duration delay,
    String key,
    Map<String, dynamic> debounceTimers,
  ) {
    if (debounceTimers.containsKey(key)) {
      (debounceTimers[key] as dynamic)?.cancel();
    }
    debounceTimers[key] = Future.delayed(delay, function);
  }
}
