// ProfileScreen
import 'package:flutter/material.dart';
import '../../core/services/post_service.dart';
import '../../data/models/post.dart';
import '../../data/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final PostService _postService = PostService();
  final String _userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  UserModel? _user;
  List<Post> _posts = [];
  bool _isLoading = true;
  String? _error;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _loadUserDetailsAndPosts();
  }

  // ...existing code...

  Future<void> _loadUserDetailsAndPosts() async {
    try {
      // Fetch user details
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(_userId)
              .get();
      if (userDoc.exists) {
        _user = UserModel.fromFirestore(userDoc.data()!, _userId);
      }
      // Fetch posts
      final allPosts = await _postService.getAllPosts();
      final userPosts =
          allPosts.where((post) => post.userId == _userId).toList();
      if (mounted) {
        setState(() {
          _posts = userPosts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0EBE3),
      body: SafeArea(
        child: Column(
          children: [
            // Profile header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Color(0xFF002924),
                    child: Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _user?.name ?? 'Art Lover',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF002924),
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_user?.email != null)
                          Text(
                            'Email: ${_user!.email}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        if (_user?.bio != null)
                          Text(
                            'Bio: ${_user!.bio}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        if (_user?.location != null)
                          Text(
                            'Location: ${_user!.location}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        if (_user?.audioUrl != null)
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  _isPlaying ? Icons.pause : Icons.volume_up,
                                  color: Color(0xFF002924),
                                ),
                                onPressed: () async {
                                  if (_isPlaying) {
                                    await _audioPlayer.pause();
                                    setState(() => _isPlaying = false);
                                  } else {
                                    final audioUrl = _user!.audioUrl!;
                                    if (audioUrl.startsWith('data:audio')) {
                                      final base64Str =
                                          audioUrl.split(',').last;
                                      try {
                                        final bytes = base64Decode(base64Str);
                                        await _audioPlayer.play(
                                          BytesSource(bytes),
                                        );
                                        setState(() => _isPlaying = true);
                                      } catch (e) {
                                        print('Audio playback error: $e');
                                      }
                                    } else {
                                      await _audioPlayer.play(
                                        UrlSource(audioUrl),
                                      );
                                      setState(() => _isPlaying = true);
                                    }
                                  }
                                },
                              ),
                              const Text('Listen to intro'),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Posts grid
            Expanded(
              child:
                  _isLoading
                      ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF002924),
                        ),
                      )
                      : _error != null
                      ? Center(child: Text('Error: $_error'))
                      : _posts.isEmpty
                      ? const Center(child: Text('No posts yet.'))
                      : GridView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.8,
                            ),
                        itemCount: _posts.length,
                        itemBuilder: (context, index) {
                          final post = _posts[index];
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                            child: InkWell(
                              onTap: () {
                                // Show post detail overlay (disabled, not implemented)
                                // Navigator.of(context).push(
                                //   PageRouteBuilder(
                                //     opaque: false,
                                //     pageBuilder:
                                //         (BuildContext context, _, __) =>
                                //             PostDetailOverlay(post: post),
                                //     transitionsBuilder: (
                                //       context,
                                //       animation,
                                //       secondaryAnimation,
                                //       child,
                                //     ) {
                                //       return FadeTransition(
                                //         opacity: animation,
                                //         child: child,
                                //       );
                                //     },
                                //   ),
                                // );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(16),
                                      ),
                                      child:
                                          post.imageUrl != null
                                              ? Image.network(
                                                post.imageUrl!,
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                              )
                                              : Container(
                                                color: Colors.grey[200],
                                                child: const Center(
                                                  child: Icon(
                                                    Icons.image,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Text(
                                      post.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color(0xFF002924),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0,
                                    ),
                                    child: Text(
                                      post.caption ?? '',
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        fontSize: 14,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
