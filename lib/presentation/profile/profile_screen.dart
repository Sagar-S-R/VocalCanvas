// ProfileScreen
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/services/post_service.dart';
import '../../data/models/post.dart';
import '../../data/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import '../widgets/post_detail_screen.dart';
import 'package:easy_localization/easy_localization.dart';

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
      // Subscribe to user's posts stream for live updates
      _postService.getUserPostsStream(_userId).listen((userPosts) {
        if (mounted) {
          setState(() {
            _posts = userPosts;
            _isLoading = false;
          });
        }
      });
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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Instagram-style Profile header
            Container(
              padding: const EdgeInsets.only(top: 40, bottom: 24, left: 24, right: 24),
              child: Column(
                children: [
                  // Centered Profile Picture
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: theme.colorScheme.primary,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Name
                  Text(
                    _user?.name ?? 'Art Lover',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ) ?? const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  
                  // Bio/Intro paragraph
                  if (_user?.bio != null && _user!.bio!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        _user!.bio!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 15,
                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                        ) ?? TextStyle(
                          fontSize: 15,
                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  
                  // Location (if available)
                  if (_user?.location != null &&
                      _user!.location!.isNotEmpty &&
                      _user!.location!.toLowerCase() != 'unknown')
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        _user!.location!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ) ?? TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  
                  // Audio intro button
                  if (_user?.audioUrl != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          if (_isPlaying) {
                            await _audioPlayer.pause();
                            setState(() => _isPlaying = false);
                          } else {
                            final audioUrl = _user!.audioUrl!;
                            if (audioUrl.startsWith('data:audio')) {
                              final base64Str = audioUrl.split(',').last;
                              try {
                                final bytes = base64Decode(base64Str);
                                await _audioPlayer.play(BytesSource(bytes));
                                setState(() => _isPlaying = true);
                              } catch (e) {
                                print('Audio playback error: $e');
                              }
                            } else {
                              await _audioPlayer.play(UrlSource(audioUrl));
                              setState(() => _isPlaying = true);
                            }
                          }
                        },
                        icon: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          size: 18,
                        ),
                        label: Text(
                          _isPlaying ? 'pause'.tr() : 'listen_intro'.tr(),
                          style: const TextStyle(fontSize: 14),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // Posts count
                  Text(
                    '${_posts.length} ${'posts'.tr()}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            
            // Divider
            Divider(
              height: 1,
              thickness: 0.5,
              color: theme.dividerColor.withOpacity(0.3),
            ),
            // Posts grid
            Expanded(
              child:
                  _isLoading
                      ? Center(
                        child: CircularProgressIndicator(
                          color: theme.colorScheme.primary,
                        ),
                      )
                      : _error != null
                      ? Center(child: Text('${'error'.tr()}: $_error'))
                      : _posts.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.photo_library_outlined,
                                  size: 64,
                                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'no_posts_yet'.tr(),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 2,
                              mainAxisSpacing: 2,
                              childAspectRatio: 1.0,
                            ),
                        itemCount: _posts.length,
                        itemBuilder: (context, index) {
                          final post = _posts[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => PostDetailScreen(post: post),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                border: Border.all(
                                  color: theme.dividerColor.withOpacity(0.1),
                                  width: 0.5,
                                ),
                              ),
                              child: post.imageUrl != null
                                  ? Image.network(
                                      post.imageUrl!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Container(
                                          color: theme.colorScheme.surface,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: theme.colorScheme.primary,
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: theme.colorScheme.surface,
                                          child: Center(
                                            child: Icon(
                                              Icons.broken_image_outlined,
                                              color: theme.colorScheme.onSurface.withOpacity(0.3),
                                              size: 32,
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                  : Container(
                                      color: theme.colorScheme.surface,
                                      child: Center(
                                        child: Icon(
                                          Icons.image_outlined,
                                          color: theme.colorScheme.onSurface.withOpacity(0.3),
                                          size: 32,
                                        ),
                                      ),
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
