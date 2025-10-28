class VideoModel {
  final String type; // 'youtube' or 'cloudinary'
  final String videoId;
  final String title;
  final String description;
  final String thumbnail;
  final String channel;
  final String views;
  final String duration;
  final String channelAvatar;
  final String published;
  final String? videoUrl; // For Cloudinary videos
  final String? publicId; // For Cloudinary videos

  const VideoModel({
    required this.type,
    required this.videoId,
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.channel,
    required this.views,
    required this.duration,
    required this.channelAvatar,
    required this.published,
    this.videoUrl,
    this.publicId,
  });

  factory VideoModel.fromYoutubeJson(Map<String, dynamic> json) {
    final snippet = json['snippet'] as Map<String, dynamic>?;
    final contentDetails = json['contentDetails'] as Map<String, dynamic>?;
    final statistics = json['statistics'] as Map<String, dynamic>?;
    final thumbnails = snippet?['thumbnails'] as Map<String, dynamic>?;
    final high = thumbnails?['high'] as Map<String, dynamic>?;
    
    final id = json['id']?.toString() ?? '';
    final title = snippet?['title']?.toString() ?? '';
    final channel = snippet?['channelTitle']?.toString() ?? '';
    final publishedAt = snippet?['publishedAt']?.toString() ?? '';
    final thumbUrl = (high?['url'] ?? 'https://img.youtube.com/vi/$id/0.jpg').toString();
    
    return VideoModel(
      type: 'youtube',
      videoId: id,
      title: title,
      description: snippet?['description']?.toString() ?? '',
      thumbnail: thumbUrl,
      channel: channel,
      views: _formatViewCount(statistics?['viewCount']),
      duration: _formatISODuration(contentDetails?['duration']?.toString()),
      channelAvatar: 'https://i.pravatar.cc/88?u=$channel',
      published: _timeAgo(publishedAt),
    );
  }

  factory VideoModel.fromCloudinaryJson(Map<String, dynamic> json) {
    final publicId = json['public_id'] as String?;
    final secureUrl = json['secure_url'] as String?;
    final createdAt = json['created_at']?.toString() ?? '';
    
    if (publicId == null || secureUrl == null) {
      throw ArgumentError('Invalid Cloudinary video data');
    }

    const cloudName = 'djipdnpai'; // This should come from config
    final thumb = 'https://res.cloudinary.com/$cloudName/video/upload/so_1,w_320,h_180,c_fill/$publicId.jpg';
    
    return VideoModel(
      type: 'cloudinary',
      videoId: publicId,
      title: publicId.split('/').last,
      description: '',
      thumbnail: thumb,
      channel: 'Cloudinary',
      views: json['views']?.toString() ?? '—',
      duration: _formatDurationSeconds(json['duration']?.toInt()),
      channelAvatar: 'https://res.cloudinary.com/$cloudName/image/upload/w_88,h_88,c_fill/yt-avatar.jpg',
      published: _timeAgo(createdAt),
      videoUrl: secureUrl,
      publicId: publicId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'videoId': videoId,
      'title': title,
      'description': description,
      'thumbnail': thumbnail,
      'channel': channel,
      'views': views,
      'duration': duration,
      'channelAvatar': channelAvatar,
      'published': published,
      if (videoUrl != null) 'videoUrl': videoUrl,
      if (publicId != null) 'publicId': publicId,
    };
  }

  // Static helper methods for formatting
  static String _formatViewCount(dynamic v) {
    if (v == null) return '—';
    final n = int.tryParse(v.toString());
    if (n == null) return '—';
    if (n >= 1000000000) return '${(n / 1000000000).toStringAsFixed(1)}B';
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }

  static String _formatISODuration(String? iso) {
    if (iso == null || iso.isEmpty) return '0:00';
    // Parse ISO8601 duration like PT1H2M10S
    final regex = RegExp(r'^PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?$');
    final m = regex.firstMatch(iso);
    if (m == null) return '0:00';
    final h = int.tryParse(m.group(1) ?? '0') ?? 0;
    final min = int.tryParse(m.group(2) ?? '0') ?? 0;
    final sec = int.tryParse(m.group(3) ?? '0') ?? 0;
    final mm = min.toString().padLeft(2, '0');
    final ss = sec.toString().padLeft(2, '0');
    if (h > 0) {
      return '$h:$mm:$ss';
    }
    return '$min:$ss';
  }

  static String _formatDurationSeconds(int? seconds) {
    if (seconds == null) return '0:00';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    final ss = s.toString().padLeft(2, '0');
    return '$m:$ss';
  }

  static String _timeAgo(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inDays >= 365) return '${(diff.inDays / 365).floor()} years ago';
      if (diff.inDays >= 30) return '${(diff.inDays / 30).floor()} months ago';
      if (diff.inDays >= 7) return '${(diff.inDays / 7).floor()} weeks ago';
      if (diff.inDays >= 1) return '${diff.inDays} days ago';
      if (diff.inHours >= 1) return '${diff.inHours} hours ago';
      if (diff.inMinutes >= 1) return '${diff.inMinutes} minutes ago';
      return 'just now';
    } catch (_) {
      return '';
    }
  }
}