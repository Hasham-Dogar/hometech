import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

import '../models/video_model.dart';
import '../config/video_config.dart';
import '../utils/video_utils.dart';

class VideoPlayerManager {
  // Player controllers
  YoutubePlayerController? _ytController;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  // Autoplay management
  Timer? _countdownTimer;
  int _secondsToNext = VideoConfig.autoplayCountdownSeconds;
  int? _pendingNextIndex;
  bool _endHandled = false;

  // Settings
  bool _autoplayNext = false;

  // Getters
  YoutubePlayerController? get youtubeController => _ytController;
  ChewieController? get chewieController => _chewieController;
  VideoPlayerController? get videoController => _videoController;
  bool get hasActivePlayer => _ytController != null;
  bool get isAutoplayEnabled => _autoplayNext;

  // Callbacks
  VoidCallback? onVideoEnded;
  Function(int)? onAutoplayNextVideo;
  VoidCallback? onShowNextOverlay;
  VoidCallback? onHideNextOverlay;

  VideoPlayerManager({
    this.onVideoEnded,
    this.onAutoplayNextVideo,
    this.onShowNextOverlay,
    this.onHideNextOverlay,
  });

  /// Initialize the player manager
  Future<void> initialize() async {
    await _loadPreferences();
  }

  /// Load video into appropriate player
  Future<void> loadVideo(VideoModel video) async {
    await disposeCurrentPlayer();
    _endHandled = false;

    if (video.type == 'youtube') {
      await _loadYouTubeVideo(video);
    }
  }

  /// Load YouTube video
  Future<void> _loadYouTubeVideo(VideoModel video) async {
    if (!VideoUtils.isValidYouTubeVideoId(video.videoId)) {
      throw Exception('Invalid YouTube video ID');
    }

    _ytController = YoutubePlayerController(
      initialVideoId: video.videoId,
      flags: const YoutubePlayerFlags(autoPlay: true, mute: false),
    );

    _ytController!.addListener(_onYouTubeTick);
  }

  /// Handle YouTube player state changes
  void _onYouTubeTick() {
    final controller = _ytController;
    if (controller == null) return;

    final value = controller.value;
    if (!_endHandled &&
        value.isReady &&
        value.playerState == PlayerState.ended) {
      _endHandled = true;
      _handleVideoEnded();
    }
  }

  /// Handle native video player state changes
  void _onNativeTick() {
    final controller = _videoController;
    if (controller == null) return;

    final value = controller.value;
    if (!value.isInitialized) return;

    final duration = value.duration;
    final position = value.position;
    final remaining = duration - position;

    if (!_endHandled && remaining.inMilliseconds <= 500 && !value.isPlaying) {
      _endHandled = true;
      _handleVideoEnded();
    }
  }

  /// Handle video end event
  void _handleVideoEnded() {
    onVideoEnded?.call();

    if (_autoplayNext) {
      startAutoplayCountdown();
    }
  }

  /// Start autoplay countdown
  void startAutoplayCountdown({int? nextVideoIndex}) {
    _countdownTimer?.cancel();
    _pendingNextIndex = nextVideoIndex;
    _secondsToNext = VideoConfig.autoplayCountdownSeconds;

    onShowNextOverlay?.call();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsToNext <= 1) {
        timer.cancel();
        _playNextNow();
      } else {
        _secondsToNext--;
      }
    });
  }

  /// Cancel autoplay countdown
  void cancelAutoplay() {
    _countdownTimer?.cancel();
    _pendingNextIndex = null;
    onHideNextOverlay?.call();
  }

  /// Play next video immediately
  void _playNextNow() {
    _countdownTimer?.cancel();
    final nextIndex = _pendingNextIndex;
    _pendingNextIndex = null;

    onHideNextOverlay?.call();

    if (nextIndex != null) {
      onAutoplayNextVideo?.call(nextIndex);
    }
  }

  /// Set autoplay preference
  Future<void> setAutoplayEnabled(bool enabled) async {
    _autoplayNext = enabled;
    await VideoUtils.saveAutoplayPreference(enabled);

    if (!enabled) {
      cancelAutoplay();
    }
  }

  /// Get current playback position
  Duration? getCurrentPosition() {
    if (_videoController?.value.isInitialized == true) {
      return _videoController!.value.position;
    }

    // YouTube controller doesn't expose position directly
    return null;
  }

  /// Get total duration
  Duration? getDuration() {
    if (_videoController?.value.isInitialized == true) {
      return _videoController!.value.duration;
    }

    // YouTube controller doesn't expose duration directly
    return null;
  }

  /// Check if video is playing
  bool get isPlaying {
    if (_videoController?.value.isInitialized == true) {
      return _videoController!.value.isPlaying;
    }

    if (_ytController != null) {
      return _ytController!.value.playerState == PlayerState.playing;
    }

    return false;
  }

  /// Pause/resume playback
  Future<void> togglePlayback() async {
    if (_videoController?.value.isInitialized == true) {
      if (_videoController!.value.isPlaying) {
        await _videoController!.pause();
      } else {
        await _videoController!.play();
      }
    }

    if (_ytController != null) {
      if (_ytController!.value.playerState == PlayerState.playing) {
        _ytController!.pause();
      } else {
        _ytController!.play();
      }
    }
  }

  /// Load user preferences
  Future<void> _loadPreferences() async {
    _autoplayNext = await VideoUtils.loadAutoplayPreference();
  }

  /// Dispose current player
  Future<void> disposeCurrentPlayer() async {
    _countdownTimer?.cancel();

    _ytController?.removeListener(_onYouTubeTick);
    _ytController?.dispose();
    _ytController = null;

    _videoController?.removeListener(_onNativeTick);
    await _videoController?.dispose();
    _videoController = null;

    _chewieController?.dispose();
    _chewieController = null;

    _pendingNextIndex = null;
    onHideNextOverlay?.call();

    // Reset orientation to portrait when closing player
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  /// Dispose all resources
  Future<void> dispose() async {
    await disposeCurrentPlayer();
  }

  // Getters for autoplay state
  int get secondsToNext => _secondsToNext;
  int? get pendingNextIndex => _pendingNextIndex;
  bool get hasActiveCountdown => _countdownTimer?.isActive == true;
}
