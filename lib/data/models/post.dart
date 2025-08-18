import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String userId;
  final String title;
  final String content;
  final String? caption; // Added caption
  final String? imageUrl;
  final String? location;
  final List<String> hashtags;
  final DateTime timestamp;
  final List<String> likes;
  final int commentsCount;

  Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    this.caption, // Added caption
    this.imageUrl,
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
      content: data['content'] ?? '',
      caption: data['caption'], // Added caption
      imageUrl: data['imageUrl'],
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
      'content': content,
      'caption': caption, // Added caption
      'imageUrl': imageUrl,
      'location': location,
      'hashtags': hashtags,
      'timestamp': Timestamp.fromDate(timestamp),
      'likes': likes,
      'commentsCount': commentsCount,
    };
  }
}
