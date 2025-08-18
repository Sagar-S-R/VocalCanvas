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
    required String title,
    required String content,
    required String userId,
    String? caption,
    String? location,
    List<String>? hashtags,
    File? imageFile,
    XFile? webImageFile,
  }) async {
    String? imageUrl;

    // Handle image upload for both web and mobile
    if (webImageFile != null && kIsWeb) {
      // For web, convert image to base64 and store directly in Firestore
      // In a production app, you'd want to use a proper storage service
      final bytes = await webImageFile.readAsBytes();
      final base64String = base64Encode(bytes);
      imageUrl = 'data:image/jpeg;base64,$base64String';
    } else if (imageFile != null && !kIsWeb) {
      // For mobile, you would typically upload to Firebase Storage
      // For now, we'll skip mobile image upload since Firebase Storage was removed
      imageUrl = null;
    }

    final newPost = Post(
      id: '', // Firestore will generate this
      title: title,
      content: content,
      caption: caption,
      userId: userId,
      imageUrl: imageUrl,
      location: location ?? 'Default Location',
      hashtags: hashtags ?? [],
      timestamp: DateTime.now(),
      likes: [],
      commentsCount: 0,
    );

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
}
