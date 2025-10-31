import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/video_config.dart';
import '../models/video_model.dart';
import '../models/comment_model.dart';
import '../utils/video_utils.dart';

class VideoService {
  VideoService._();
  static final VideoService _instance = VideoService._();
  static VideoService get instance => _instance;

  /// Fetch YouTube popular/trending videos
  Future<VideoServiceResult> fetchYoutubePopular({
    String? pageToken,
    int maxResults = 20,
  }) async {
    if (!VideoConfig.isYouTubeConfigured) {
      throw Exception('YouTube API key not configured');
    }

    try {
      final params = <String, String>{
        'part': 'snippet,contentDetails,statistics',
        'chart': 'mostPopular',
        'maxResults': maxResults.toString(),
        'regionCode': VideoConfig.defaultRegionCode,
        'key': VideoConfig.ytApiKey!,
      };

      if (pageToken != null && pageToken.isNotEmpty) {
        params['pageToken'] = pageToken;
      }

      final uri = Uri.https(
        'www.googleapis.com',
        '/youtube/v3/videos',
        params,
      );

      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final nextPageToken = (data['nextPageToken'] as String?) ?? '';
      final items = (data['items'] as List<dynamic>? ?? []);

      final videos = <VideoModel>[];
      for (final item in items) {
        try {
          final video = VideoModel.fromYoutubeJson(item as Map<String, dynamic>);
          videos.add(video);
        } catch (e) {
          // Skip invalid video entries
          continue;
        }
      }

      return VideoServiceResult(
        videos: videos,
        nextPageToken: nextPageToken,
        totalResults: data['pageInfo']?['totalResults'] as int?,
      );
    } catch (e) {
      throw Exception(VideoUtils.getApiErrorMessage('YouTube', e));
    }
  }

  /// Search YouTube videos
  Future<VideoServiceResult> fetchYoutubeSearch({
    required String query,
    String? pageToken,
    int maxResults = 20,
  }) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      return VideoServiceResult(videos: [], nextPageToken: '');
    }

    if (!VideoConfig.isYouTubeConfigured) {
      throw Exception('YouTube API key not configured');
    }

    try {
      // First, search for video IDs
      final searchParams = <String, String>{
        'part': 'snippet',
        'type': 'video',
        'maxResults': maxResults.toString(),
        'q': trimmedQuery,
        'key': VideoConfig.ytApiKey!,
      };

      if (pageToken != null && pageToken.isNotEmpty) {
        searchParams['pageToken'] = pageToken;
      }

      final searchUri = Uri.https(
        'www.googleapis.com',
        '/youtube/v3/search',
        searchParams,
      );

      final searchResponse = await http.get(searchUri);

      if (searchResponse.statusCode != 200) {
        throw Exception('HTTP ${searchResponse.statusCode}: ${searchResponse.body}');
      }

      final searchData = json.decode(searchResponse.body) as Map<String, dynamic>;
      final nextPageToken = (searchData['nextPageToken'] as String?) ?? '';
      final searchItems = (searchData['items'] as List<dynamic>? ?? []);

      if (searchItems.isEmpty) {
        return VideoServiceResult(videos: [], nextPageToken: '');
      }

      // Collect video IDs
      final videoIds = <String>[];
      for (final item in searchItems) {
        final itemMap = item as Map<String, dynamic>;
        final id = (itemMap['id'] as Map<String, dynamic>?)?['videoId']?.toString();
        if (id != null) {
          videoIds.add(id);
        }
      }

      if (videoIds.isEmpty) {
        return VideoServiceResult(videos: [], nextPageToken: '');
      }

      // Now fetch detailed video information
      final videoParams = <String, String>{
        'part': 'snippet,contentDetails,statistics',
        'id': videoIds.join(','),
        'key': VideoConfig.ytApiKey!,
        'maxResults': '50',
      };

      final videoUri = Uri.https(
        'www.googleapis.com',
        '/youtube/v3/videos',
        videoParams,
      );

      final videoResponse = await http.get(videoUri);

      if (videoResponse.statusCode != 200) {
        throw Exception('HTTP ${videoResponse.statusCode}: ${videoResponse.body}');
      }

      final videoData = json.decode(videoResponse.body) as Map<String, dynamic>;
      final videoItems = (videoData['items'] as List<dynamic>? ?? []);

      final videos = <VideoModel>[];
      for (final item in videoItems) {
        try {
          final video = VideoModel.fromYoutubeJson(item as Map<String, dynamic>);
          videos.add(video);
        } catch (e) {
          // Skip invalid video entries
          continue;
        }
      }

      return VideoServiceResult(
        videos: videos,
        nextPageToken: nextPageToken,
        totalResults: searchData['pageInfo']?['totalResults'] as int?,
      );
    } catch (e) {
      throw Exception(VideoUtils.getApiErrorMessage('YouTube', e));
    }
  }

  /// Fetch Cloudinary videos
  Future<VideoServiceResult> fetchCloudinaryVideos({
    String? prefix,
    int maxResults = 50,
  }) async {
    if (!VideoConfig.isCloudinaryConfigured) {
      throw Exception('Cloudinary API credentials not configured');
    }

    try {
      final folderPrefix = prefix ?? VideoConfig.folderPrefix;
      final uri = Uri.parse(
        '${VideoConfig.cloudinaryApiUrl}/resources/video/upload?prefix=$folderPrefix&max_results=$maxResults',
      );

      final auth = 'Basic ' + 
          base64Encode(utf8.encode('${VideoConfig.apiKey!}:${VideoConfig.apiSecret!}'));

      final response = await http.get(
        uri,
        headers: {'Authorization': auth},
      );

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final resources = (data['resources'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();

      final videos = <VideoModel>[];
      for (final resource in resources) {
        try {
          final video = VideoModel.fromCloudinaryJson(resource);
          videos.add(video);
        } catch (e) {
          // Skip invalid resource entries
          continue;
        }
      }

      return VideoServiceResult(
        videos: videos,
        nextPageToken: '', // Cloudinary doesn't use page tokens
        totalResults: videos.length,
      );
    } catch (e) {
      throw Exception(VideoUtils.getApiErrorMessage('Cloudinary', e));
    }
  }

  /// Perform local search in video list (fallback when APIs are not available)
  Future<VideoServiceResult> performLocalSearch({
    required List<VideoModel> videos,
    required String query,
    int? excludeIndex,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate network delay
    
    final filteredVideos = VideoUtils.filterVideos(
      videos,
      query,
      excludeIndex: excludeIndex,
    );

    return VideoServiceResult(
      videos: filteredVideos,
      nextPageToken: '',
      totalResults: filteredVideos.length,
    );
  }

  /// Get service availability status
  Map<String, bool> getServiceStatus() {
    return {
      'youtube': VideoConfig.isYouTubeConfigured,
      'cloudinary': VideoConfig.isCloudinaryConfigured,
    };
  }
  
  /// Fetch YouTube comments for a video (read-only)
  Future<CommentsResult> fetchYoutubeComments({
    required String videoId,
    String? pageToken,
    int maxResults = 20,
    String order = 'relevance', // or 'time'
  }) async {
    if (!VideoConfig.isYouTubeConfigured) {
      throw Exception('YouTube API key not configured');
    }
    if (videoId.isEmpty) {
      throw Exception('Missing videoId');
    }

    try {
      final params = <String, String>{
        'part': 'snippet,replies',
        'videoId': videoId,
        'maxResults': maxResults.toString(),
        'textFormat': 'plainText',
        'order': order,
        'key': VideoConfig.ytApiKey!,
      };
      if (pageToken != null && pageToken.isNotEmpty) {
        params['pageToken'] = pageToken;
      }

      final uri = Uri.https('www.googleapis.com', '/youtube/v3/commentThreads', params);
      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final nextPageToken = (data['nextPageToken'] as String?) ?? '';
      final items = (data['items'] as List<dynamic>? ?? []);

      final comments = <CommentModel>[];
      for (final item in items) {
        try {
          comments.add(CommentModel.fromYouTubeThread(item as Map<String, dynamic>));
        } catch (_) {
          // skip malformed
        }
      }

      return CommentsResult(
        comments: comments,
        nextPageToken: nextPageToken,
        totalResults: data['pageInfo']?['totalResults'] as int?,
      );
    } catch (e) {
      throw Exception(VideoUtils.getApiErrorMessage('YouTube', e));
    }
  }
  
  /// Get configuration issues
  List<String> getConfigurationIssues() {
    final issues = <String>[];
    
    if (!VideoConfig.isYouTubeConfigured) {
      issues.add('YouTube API key not configured in .env file');
    }
    
    if (!VideoConfig.isCloudinaryConfigured) {
      issues.add('Cloudinary credentials not configured in .env file');
    }
    
    return issues;
  }
}

/// Result wrapper for video service operations
class VideoServiceResult {
  final List<VideoModel> videos;
  final String nextPageToken;
  final int? totalResults;

  const VideoServiceResult({
    required this.videos,
    required this.nextPageToken,
    this.totalResults,
  });

  bool get hasNextPage => nextPageToken.isNotEmpty;
  bool get isEmpty => videos.isEmpty;
  int get count => videos.length;
}

/// Result wrapper for YouTube comments
class CommentsResult {
  final List<CommentModel> comments;
  final String nextPageToken;
  final int? totalResults;

  const CommentsResult({
    required this.comments,
    required this.nextPageToken,
    this.totalResults,
  });

  bool get hasNextPage => nextPageToken.isNotEmpty;
  bool get isEmpty => comments.isEmpty;
  int get count => comments.length;
}
