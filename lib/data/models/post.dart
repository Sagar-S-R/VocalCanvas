import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String userId;
  final String title;
  final String content_en;
  final String content_hi;
  final String content_kn;
  final String? caption; // Added caption
  final String? imageUrl;
  final String? audioUrl;
  final String? location;
  final List<String> hashtags;
  final DateTime timestamp;
  final List<String> likes;
  final int commentsCount;

  Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.content_en,
    required this.content_hi,
    required this.content_kn,
    this.caption, // Added caption
    this.imageUrl,
    this.audioUrl,
    this.location,
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
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      content_en: data['content_en'] ?? '',
      content_hi: data['content_hi'] ?? '',
      content_kn: data['content_kn'] ?? '',
      caption: data['caption'],
      imageUrl: data['imageUrl'],
      audioUrl: data['audioUrl'],
      location: data['location'],
      hashtags: hashtags,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      likes: List<String>.from(data['likes'] ?? []),
      commentsCount: data['commentsCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'content_en': content_en,
      'content_hi': content_hi,
      'content_kn': content_kn,
      'caption': caption,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'location': location,
      'hashtags': hashtags,
      'timestamp': Timestamp.fromDate(timestamp),
      'likes': likes,
      'commentsCount': commentsCount,
    };
  }
}
