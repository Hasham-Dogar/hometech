// ignore: unused_import
import 'package:flutter/foundation.dart';

class CommentModel {
  final String id;
  final String authorDisplayName;
  final String authorProfileImageUrl;
  final String text;
  final DateTime publishedAt;
  final int likeCount;
  final int totalReplyCount;
  final List<CommentModel> replies;

  const CommentModel({
    required this.id,
    required this.authorDisplayName,
    required this.authorProfileImageUrl,
    required this.text,
    required this.publishedAt,
    required this.likeCount,
    required this.totalReplyCount,
    this.replies = const [],
  });

  factory CommentModel.fromYouTubeThread(Map<String, dynamic> json) {
    final snippet = (json['snippet'] ?? {}) as Map<String, dynamic>;
    final topLevel =
        ((snippet['topLevelComment'] ?? {}) as Map<String, dynamic>)['snippet']
            as Map<String, dynamic>?;

    final id = json['id']?.toString() ?? '';
    final totalReplies = (snippet['totalReplyCount'] as int?) ?? 0;

    final top = CommentModel(
      id: id,
      authorDisplayName:
          topLevel?['authorDisplayName']?.toString() ?? 'Unknown',
      authorProfileImageUrl:
          topLevel?['authorProfileImageUrl']?.toString() ??
          'https://i.pravatar.cc/48',
      text: (topLevel?['textOriginal'] ?? topLevel?['textDisplay'] ?? '')
          .toString(),
      publishedAt:
          DateTime.tryParse(topLevel?['publishedAt']?.toString() ?? '') ??
          DateTime.now(),
      likeCount: int.tryParse((topLevel?['likeCount'] ?? 0).toString()) ?? 0,
      totalReplyCount: totalReplies,
    );

    // Parse replies if present
    final repliesContainer = json['replies'] as Map<String, dynamic>?;
    final items = (repliesContainer?['comments'] as List<dynamic>?) ?? const [];
    final replies = items.map((c) {
      final s = (c as Map<String, dynamic>)['snippet'] as Map<String, dynamic>?;
      return CommentModel(
        id: c['id']?.toString() ?? '',
        authorDisplayName: s?['authorDisplayName']?.toString() ?? 'Unknown',
        authorProfileImageUrl:
            s?['authorProfileImageUrl']?.toString() ??
            'https://i.pravatar.cc/48',
        text: (s?['textOriginal'] ?? s?['textDisplay'] ?? '').toString(),
        publishedAt:
            DateTime.tryParse(s?['publishedAt']?.toString() ?? '') ??
            DateTime.now(),
        likeCount: int.tryParse((s?['likeCount'] ?? 0).toString()) ?? 0,
        totalReplyCount: 0,
      );
    }).toList();

    return top.copyWith(replies: replies);
  }

  CommentModel copyWith({
    String? id,
    String? authorDisplayName,
    String? authorProfileImageUrl,
    String? text,
    DateTime? publishedAt,
    int? likeCount,
    int? totalReplyCount,
    List<CommentModel>? replies,
  }) {
    return CommentModel(
      id: id ?? this.id,
      authorDisplayName: authorDisplayName ?? this.authorDisplayName,
      authorProfileImageUrl:
          authorProfileImageUrl ?? this.authorProfileImageUrl,
      text: text ?? this.text,
      publishedAt: publishedAt ?? this.publishedAt,
      likeCount: likeCount ?? this.likeCount,
      totalReplyCount: totalReplyCount ?? this.totalReplyCount,
      replies: replies ?? this.replies,
    );
  }
}
