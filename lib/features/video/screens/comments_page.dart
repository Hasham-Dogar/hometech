import 'package:flutter/material.dart';
import '../models/video_model.dart';
import '../models/comment_model.dart';
import '../services/video_service.dart';

class CommentsPage extends StatefulWidget {
  final VideoModel video;
  const CommentsPage({super.key, required this.video});

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  final ScrollController _scrollController = ScrollController();

  List<CommentModel> _comments = [];
  String _nextPageToken = '';
  bool _isLoading = false;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadInitial();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitial() async {
    setState(() => _isLoading = true);
    try {
      final res = await VideoService.instance.fetchYoutubeComments(
        videoId: widget.video.videoId,
      );
      setState(() {
        _comments = res.comments;
        _nextPageToken = res.nextPageToken;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load comments: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onScroll() {
    if (_isLoadingMore || _nextPageToken.isEmpty) return;
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.maxScrollExtent - pos.pixels < 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || _nextPageToken.isEmpty) return;
    setState(() => _isLoadingMore = true);
    try {
      final res = await VideoService.instance.fetchYoutubeComments(
        videoId: widget.video.videoId,
        pageToken: _nextPageToken,
      );
      setState(() {
        _comments.addAll(res.comments);
        _nextPageToken = res.nextPageToken;
      });
    } finally {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _onRefresh() async {
    await _loadInitial();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
      ),
      body: _isLoading
          ? const LinearProgressIndicator(minHeight: 2)
          : RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.all(12),
                itemBuilder: (context, index) {
                  if (index == _comments.length) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: _isLoadingMore
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const SizedBox.shrink(),
                      ),
                    );
                  }
                  final c = _comments[index];
                  return _CommentThreadTile(comment: c);
                },
                separatorBuilder: (_, __) => const Divider(height: 16),
                itemCount: _comments.length + 1,
              ),
            ),
    );
  }
}

class _CommentThreadTile extends StatelessWidget {
  final CommentModel comment;
  const _CommentThreadTile({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(comment.authorProfileImageUrl),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          comment.authorDisplayName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _timeAgo(comment.publishedAt),
                        style: const TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    comment.text,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.thumb_up_alt_outlined, size: 16, color: Colors.black45),
                      const SizedBox(width: 6),
                      Text('${comment.likeCount}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                      const SizedBox(width: 16),
                      const Icon(Icons.thumb_down_alt_outlined, size: 16, color: Colors.black45),
                      const SizedBox(width: 16),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Reply'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        if (comment.replies.isNotEmpty) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 42),
            child: Column(
              children: comment.replies
                  .map((r) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundImage: NetworkImage(r.authorProfileImageUrl),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          r.authorDisplayName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        _timeAgo(r.publishedAt),
                                        style: const TextStyle(color: Colors.black54, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(r.text),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ],
    );
  }
}

String _timeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inDays >= 365) return '${(diff.inDays / 365).floor()} years ago';
  if (diff.inDays >= 30) return '${(diff.inDays / 30).floor()} months ago';
  if (diff.inDays >= 7) return '${(diff.inDays / 7).floor()} weeks ago';
  if (diff.inDays >= 1) return '${diff.inDays} days ago';
  if (diff.inHours >= 1) return '${diff.inHours} hours ago';
  if (diff.inMinutes >= 1) return '${diff.inMinutes} minutes ago';
  return 'just now';
}
