import '../models/video_model.dart';

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
