// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:chewie/chewie.dart';

import '../config/video_config.dart';
import '../models/video_model.dart';
import '../services/video_service.dart';
import '../utils/video_utils.dart';
import '../controllers/video_player_controller.dart';
import '../widgets/video_player_widgets.dart';
import '../widgets/video_feed_widgets.dart';
import '../widgets/video_ui_components.dart';

class VideoPlayerPage extends StatefulWidget {
  const VideoPlayerPage({super.key});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  // Data/state
  List<VideoModel> _videos = [];
  int _currentIndex = -1;
  String? _nextPageToken;
  String _feedMode = 'none'; // 'ytPopular' | 'ytSearch' | 'cloudinary'
  String? _searchQuery;

  // UI/state
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  bool _showSearch = false;
  bool _isFetching = false;
  bool _isSearching = false;
  bool _isLoadingMore = false;
  bool _isMinimized = false;
  bool _showNextOverlay = false;
  DateTime? _lastBackPressedAt;

  late final VideoPlayerManager _playerManager;

  @override
  void initState() {
    super.initState();
    VideoConfig.loadEnvVariables();

    _playerManager = VideoPlayerManager(
      onVideoEnded: _onCurrentVideoEnded,
      onAutoplayNextVideo: (idx) => _onSelect(idx, fromAutoplay: true),
      onShowNextOverlay: () => setState(() => _showNextOverlay = true),
      onHideNextOverlay: () => setState(() => _showNextOverlay = false),
    );
    _playerManager.initialize();

    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (VideoConfig.isYouTubeConfigured) {
        await _loadYoutubePopular(reset: true);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Set YOUTUBE_API_KEY in .env to load live YouTube feed.',
              ),
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _scrollController.dispose();
    _playerManager.dispose();
    super.dispose();
  }

  // Loading and pagination
  void _onScroll() {
    if (_isLoadingMore || !_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.maxScrollExtent - pos.pixels < VideoConfig.scrollLoadThreshold) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;
    if (!VideoConfig.isYouTubeConfigured) return;
    if (_feedMode != 'ytPopular' && _feedMode != 'ytSearch') return;
    if (_nextPageToken == null || _nextPageToken!.isEmpty) return;

    setState(() => _isLoadingMore = true);
    try {
      if (_feedMode == 'ytPopular') {
        final res = await VideoService.instance.fetchYoutubePopular(
          pageToken: _nextPageToken,
        );
        setState(() {
          _videos.addAll(res.videos);
          _nextPageToken = res.nextPageToken;
        });
      } else {
        final res = await VideoService.instance.fetchYoutubeSearch(
          query: _searchQuery ?? '',
          pageToken: _nextPageToken,
        );
        setState(() {
          _videos.addAll(res.videos);
          _nextPageToken = res.nextPageToken;
        });
      }
    } finally {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _onRefresh() async {
    if (!VideoConfig.isYouTubeConfigured) {
      await Future.delayed(const Duration(milliseconds: 200));
      return;
    }
    if (_feedMode == 'ytPopular') {
      await _loadYoutubePopular(reset: true);
    } else if (_feedMode == 'ytSearch') {
      await _performSearch(_searchQuery ?? _searchController.text.trim());
    }
  }

  // Fetchers
  Future<void> _loadYoutubePopular({bool reset = false}) async {
    try {
      if (mounted) setState(() => _isFetching = true);
      final res = await VideoService.instance.fetchYoutubePopular();
      setState(() {
        _feedMode = 'ytPopular';
        _videos = res.videos;
        _nextPageToken = res.nextPageToken;
        _currentIndex = -1;
      });
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load YouTube trending: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isFetching = false);
    }
  }

  Future<void> _performSearch(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;

    if (!VideoConfig.isYouTubeConfigured) {
      final idx = _videos.indexWhere(
        (v) =>
            v.title.toLowerCase().contains(q.toLowerCase()) ||
            v.channel.toLowerCase().contains(q.toLowerCase()),
      );
      if (idx != -1) _onSelect(idx);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'YouTube search requires YOUTUBE_API_KEY. Filtered locally.',
            ),
          ),
        );
      }
      return;
    }

    setState(() => _isSearching = true);
    try {
      final res = await VideoService.instance.fetchYoutubeSearch(query: q);
      setState(() {
        _feedMode = 'ytSearch';
        _searchQuery = q;
        _videos = res.videos;
        _nextPageToken = res.nextPageToken;
        _currentIndex = -1;
      });
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('YouTube search failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  // Selection and playback
  Future<void> _onSelect(int index, {bool fromAutoplay = false}) async {
    if (index < 0 || index >= _videos.length) return;
    setState(() {
      _currentIndex = index;
      _isMinimized = false;
    });
    await _playerManager.loadVideo(_videos[_currentIndex]);
    if (!fromAutoplay) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  void _onCurrentVideoEnded() {
    if (!_playerManager.isAutoplayEnabled) return;
    final next = VideoUtils.getNextPlayableIndex(_videos, _currentIndex);
    if (next == null) return;
    _playerManager.startAutoplayCountdown(nextVideoIndex: next);
  }

  Future<bool> _handleBackPressed() async {
    final hasSelection =
        _videos.isNotEmpty &&
        _currentIndex >= 0 &&
        _currentIndex < _videos.length;
    if (hasSelection && !_isMinimized) {
      setState(() => _isMinimized = true);
      return false;
    }
    if (hasSelection && _isMinimized) {
      await _closePlayer();
      return false;
    }
    final now = DateTime.now();
    if (_lastBackPressedAt == null ||
        now.difference(_lastBackPressedAt!) > const Duration(seconds: 2)) {
      _lastBackPressedAt = now;
      if (mounted) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Press back again to exit')),
        );
      }
      return false;
    }
    return true;
  }

  Future<void> _closePlayer() async {
    await _playerManager.disposeCurrentPlayer();
    setState(() {
      _currentIndex = -1;
      _isMinimized = false;
      _showNextOverlay = false;
    });
  }

  // Build
  @override
  Widget build(BuildContext context) {
    final hasVideos = _videos.isNotEmpty;
    final bool hasSelection =
        hasVideos && _currentIndex >= 0 && _currentIndex < _videos.length;
    final VideoModel? current = hasSelection ? _videos[_currentIndex] : null;

    final query = _searchController.text.trim();
    final suggestions = VideoUtils.filterVideos(
      _videos,
      query,
      excludeIndex: _currentIndex >= 0 ? _currentIndex : null,
    );
    final feedItems = VideoUtils.getYouTubeVideos(suggestions);

    return WillPopScope(
      onWillPop: _handleBackPressed,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          titleSpacing: 0,
          title: VideoAppBarTitle(
            showSearch: _showSearch,
            searchController: _searchController,
            searchFocusNode: _searchFocus,
            onSearchChanged: (_) => setState(() {}),
            onSearchSubmitted: (value) {
              final q = value.trim();
              if (q.isEmpty) return;
              _performSearch(q);
            },
          ),
          actions: [
            if (_showSearch)
              IconButton(
                icon: const Icon(Icons.clear, color: Colors.black87),
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                },
                tooltip: 'Clear search',
              ),
            IconButton(
              icon: const Icon(Icons.cast, color: Colors.black87),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.notifications_none, color: Colors.black87),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(
                _showSearch ? Icons.close : Icons.search,
                color: Colors.black87,
              ),
              onPressed: () {
                setState(() {
                  _showSearch = !_showSearch;
                  if (!_showSearch) {
                    _searchController.clear();
                  } else {
                    Future.delayed(const Duration(milliseconds: 50), () {
                      if (mounted) _searchFocus.requestFocus();
                    });
                  }
                });
              },
            ),
            const SizedBox(width: 6),
          ],
        ),
        body: Stack(
          children: [
            RefreshIndicator(
              onRefresh: _onRefresh,
              color: Colors.redAccent,
              displacement: 28,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  if (hasSelection && !_isMinimized)
                    SliverToBoxAdapter(
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: CustomVideoPlayer(
                          video: current!,
                          youtubeController: _playerManager.youtubeController,
                          chewieController: _playerManager.chewieController,
                          onMinimize: () => setState(() => _isMinimized = true),
                          onClose: _closePlayer,
                        ),
                      ),
                    ),
                  if (hasSelection)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              current!.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 6),
                            VideoStatsRow(video: current),
                            const SizedBox(height: 10),
                            const ActionChips(),
                            const Divider(height: 24),
                            ChannelRow(video: current),
                            const SizedBox(height: 8),
                            VideoDescription(video: current),
                            const Divider(height: 24),
                            const CommentsPreview(),
                            const Divider(height: 24),
                            UpNextHeader(
                              autoplayEnabled: _playerManager.isAutoplayEnabled,
                              onAutoplayChanged: (v) async {
                                await _playerManager.setAutoplayEnabled(v);
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (_isFetching || _isSearching)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: LinearProgressIndicator(minHeight: 2),
                      ),
                    ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final v = feedItems[index];
                      return FeedVideoItem(
                        video: v,
                        onTap: () {
                          final newIndex = _videos.indexOf(v);
                          if (newIndex != -1) _onSelect(newIndex);
                        },
                      );
                    }, childCount: feedItems.length),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: _isLoadingMore
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_isMinimized && hasSelection)
              MiniPlayerOverlay(
                video: _videos[_currentIndex],
                youtubeController: _playerManager.youtubeController,
                chewieController: _playerManager.chewieController,
                onExpand: () => setState(() => _isMinimized = false),
                onClose: _closePlayer,
              ),
            if (_showNextOverlay)
              NextVideoOverlay(
                nextVideo: _playerManager.pendingNextIndex != null
                    ? _videos[_playerManager.pendingNextIndex!]
                    : null,
                secondsRemaining: _playerManager.secondsToNext,
                onPlayNow: () {
                  _playerManager.cancelAutoplay();
                  final next = _playerManager.pendingNextIndex;
                  if (next != null) _onSelect(next, fromAutoplay: true);
                },
                onCancel: _playerManager.cancelAutoplay,
              ),
          ],
        ),
      ),
    );
  }
}
