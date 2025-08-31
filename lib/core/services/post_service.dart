import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/post.dart';

class PostService {
  final CollectionReference postsRef = FirebaseFirestore.instance.collection(
    'posts',
  );

  Future<void> createPost({
    required String title_en,
    required String title_hi,
    required String title_kn,
    required String content_en,
    required String content_hi,
    required String content_kn,
    required String userId,
    String? caption_en,
    String? caption_hi,
    String? caption_kn,
    String? location_en,
    String? location_hi,
    String? location_kn,
    List<String>? hashtags,
    File? imageFile,
    Uint8List? audioBytes,
    XFile? webImageFile,
  }) async {
    String? imageUrl;
    String? audioUrl;

    // Handle image upload for both web and mobile
    if (webImageFile != null && kIsWeb) {
      final bytes = await webImageFile.readAsBytes();
      final base64String = base64Encode(bytes);
      imageUrl = 'data:image/jpeg;base64,$base64String';
    } else if (imageFile != null && !kIsWeb) {
      imageUrl = null;
    }

    // Handle audio upload from bytes
    if (audioBytes != null) {
      final base64String = base64Encode(audioBytes);
      audioUrl = 'data:audio/m4a;base64,$base64String';
    }

    final newPost = Post(
      id: '',
  // Ensure author is always set from current user
      title_en: title_en,
      title_hi: title_hi,
      title_kn: title_kn,
      content_en: content_en,
      content_hi: content_hi,
      content_kn: content_kn,
      caption_en: caption_en,
      caption_hi: caption_hi,
      caption_kn: caption_kn,
      userId: userId,
      imageUrl: imageUrl,
      audioUrl: audioUrl,
      location_en: location_en ?? 'Default Location',
      location_hi: location_hi ?? 'डिफ़ॉल्ट स्थान',
      location_kn: location_kn ?? 'ಡಿಫಾಲ್ಟ್ ಸ್ಥಳ',
      hashtags: hashtags ?? [],
      timestamp: DateTime.now(),
      likes: [],
      commentsCount: 0,
    );

  // Writes both userId and authorId via Post.toFirestore()
  await postsRef.add(newPost.toFirestore());
  }

  Stream<List<Post>> getPostsStream() {
    return postsRef
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList(),
        );
  }

  Stream<List<Post>> getUserPostsStream(String userId) {
    return postsRef
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList(),
        );
  }

  Future<List<Post>> getAllPosts() async {
    final querySnapshot =
        await postsRef.orderBy('timestamp', descending: true).get();

    return querySnapshot.docs.map((doc) => Post.fromFirestore(doc)).toList();
  }

  Future<void> updatePost(String postId, Map<String, dynamic> data) async {
    await postsRef.doc(postId).update(data);
  }

  Future<void> deletePost(String postId) async {
    await postsRef.doc(postId).delete();
  }

  // --- Likes ---
  Future<void> toggleLike(String postId, String userId) async {
    final postRef = postsRef.doc(postId);
    final postSnapshot = await postRef.get();

    if (postSnapshot.exists) {
      final post = Post.fromFirestore(postSnapshot);
      if (post.likes.contains(userId)) {
        // User has already liked the post, so unlike it
        postRef.update({
          'likes': FieldValue.arrayRemove([userId]),
        });
      } else {
        // User hasn't liked the post, so like it
        postRef.update({
          'likes': FieldValue.arrayUnion([userId]),
        });
      }
    }
  }

  // --- Comments ---
  Future<void> addComment(String postId, String userId, String text) async {
    final comment = {
      'userId': userId,
      'text': text,
      'timestamp': Timestamp.now(),
    };

    // Add the comment to the 'comments' subcollection
    await postsRef.doc(postId).collection('comments').add(comment);

    // Increment the commentsCount on the post
    await postsRef.doc(postId).update({
      'commentsCount': FieldValue.increment(1),
    });
  }

  Stream<QuerySnapshot> getCommentsStream(String postId) {
    return postsRef
        .doc(postId)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
