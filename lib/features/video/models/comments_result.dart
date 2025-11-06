import '../models/comment_model.dart';

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
