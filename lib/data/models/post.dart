import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String userId;
  final String title_en;
  final String title_hi;
  final String title_kn;
  final String content_en;
  final String content_hi;
  final String content_kn;
  final String? caption_en;
  final String? caption_hi;
  final String? caption_kn;
  final String? imageUrl;
  final String? audioUrl;
  final String? location_en;
  final String? location_hi;
  final String? location_kn;
  final List<String> hashtags;
  final DateTime timestamp;
  final List<String> likes;
  final int commentsCount;

  Post({
    required this.id,
    required this.userId,
    required this.title_en,
    required this.title_hi,
    required this.title_kn,
    required this.content_en,
    required this.content_hi,
    required this.content_kn,
    this.caption_en,
    this.caption_hi,
    this.caption_kn,
    this.imageUrl,
    this.audioUrl,
    this.location_en,
    this.location_hi,
    this.location_kn,
    required this.hashtags,
    required this.timestamp,
    required this.likes,
    required this.commentsCount,
  });

  factory Post.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    List<String> hashtags = [];
    if (data['hashtags'] != null) {
      if (data['hashtags'] is String) {
        // Handle old data where hashtags might be a single comma-separated string
        hashtags =
            (data['hashtags'] as String)
                .split(',')
                .map((h) => h.trim())
                .where((h) => h.isNotEmpty)
                .toList();
      } else if (data['hashtags'] is List) {
        // Handle new data where hashtags are stored as a list
        hashtags = List<String>.from(data['hashtags']);
      }
    }

    return Post(
      id: doc.id,
  // Backward/forward compatibility: prefer userId, fallback to authorId
  userId: data['userId'] ?? data['authorId'] ?? '',
      title_en: data['title_en'] ?? data['title'] ?? '',
      title_hi: data['title_hi'] ?? data['title'] ?? '',
      title_kn: data['title_kn'] ?? data['title'] ?? '',
      content_en: data['content_en'] ?? '',
      content_hi: data['content_hi'] ?? '',
      content_kn: data['content_kn'] ?? '',
      caption_en: data['caption_en'] ?? data['caption'],
      caption_hi: data['caption_hi'] ?? data['caption'],
      caption_kn: data['caption_kn'] ?? data['caption'],
      imageUrl: data['imageUrl'],
      audioUrl: data['audioUrl'],
      location_en: data['location_en'] ?? data['location'],
      location_hi: data['location_hi'] ?? data['location'],
      location_kn: data['location_kn'] ?? data['location'],
      hashtags: hashtags,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      likes: List<String>.from(data['likes'] ?? []),
      commentsCount: data['commentsCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
  // Also store authorId to satisfy code paths expecting this name
  'authorId': userId,
      'title_en': title_en,
      'title_hi': title_hi,
      'title_kn': title_kn,
      'content_en': content_en,
      'content_hi': content_hi,
      'content_kn': content_kn,
      'caption_en': caption_en,
      'caption_hi': caption_hi,
      'caption_kn': caption_kn,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'location_en': location_en,
      'location_hi': location_hi,
      'location_kn': location_kn,
      'hashtags': hashtags,
      'timestamp': Timestamp.fromDate(timestamp),
      'likes': likes,
      'commentsCount': commentsCount,
    };
  }
}