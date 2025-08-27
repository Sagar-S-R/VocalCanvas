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
  final String? userId;
  const ProfileScreen({super.key, this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  final PostService _postService = PostService();
  UserModel? _user;
  List<Post> _posts = [];
  bool _isLoading = true;
  String? _error;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  late TabController _tabController;

  String get _resolvedUserId =>
      widget.userId ?? (FirebaseAuth.instance.currentUser?.uid ?? '');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserDetailsAndPosts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // ...existing code...

  Future<void> _loadUserDetailsAndPosts() async {
    try {
      // Fetch user details
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(_resolvedUserId)
              .get();
      if (userDoc.exists) {
        _user = UserModel.fromFirestore(userDoc.data()!, _resolvedUserId);
      }
      if (mounted) {
        setState(() {
          _isLoading = false; // Stop blocking UI after user data arrives
        });
      }
      // Subscribe to user's posts stream for live updates
      _postService.getUserPostsStream(_resolvedUserId).listen((userPosts) {
        if (mounted) {
          setState(() {
            _posts = userPosts;
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
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: 400,
                floating: false,
                pinned: false,
                backgroundColor: theme.scaffoldBackgroundColor,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    padding: const EdgeInsets.only(
                      top: 40,
                      bottom: 24,
                      left: 24,
                      right: 24,
                    ),
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

                        // Name (multilingual)
                        Text(
                          _localizedName(_user, context.locale.languageCode) ??
                              'Art Lover',
                          style:
                              theme.textTheme.titleLarge?.copyWith(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ) ??
                              const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),

                        // Bio/Intro paragraph (multilingual)
                        if (_localizedBio(_user, context.locale.languageCode) !=
                                null &&
                            _localizedBio(
                              _user,
                              context.locale.languageCode,
                            )!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              _localizedBio(
                                _user,
                                context.locale.languageCode,
                              )!,
                              style:
                                  theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: 15,
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.8),
                                  ) ??
                                  TextStyle(
                                    fontSize: 15,
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.8),
                                  ),
                              textAlign: TextAlign.center,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                        // Contact info: email and phone
                        if (_user != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_user!.email.isNotEmpty)
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.email_outlined,
                                        size: 16,
                                        color: theme.colorScheme.onSurface
                                            .withOpacity(0.7),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        _user!.email,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: theme.colorScheme.onSurface
                                                  .withOpacity(0.8),
                                            ),
                                      ),
                                    ],
                                  ),
                                if (_user!.email.isNotEmpty &&
                                    (_user!.phone ?? '').isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Text(
                                      '•',
                                      style: TextStyle(
                                        color: theme.colorScheme.onSurface
                                            .withOpacity(0.5),
                                      ),
                                    ),
                                  ),
                                if ((_user!.phone ?? '').isNotEmpty)
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.phone_outlined,
                                        size: 16,
                                        color: theme.colorScheme.onSurface
                                            .withOpacity(0.7),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        _user!.phone!,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: theme.colorScheme.onSurface
                                                  .withOpacity(0.8),
                                            ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),

                        // Location (multilingual) if available
                        if (_localizedLocation(
                              _user,
                              context.locale.languageCode,
                            ) !=
                            null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              _localizedLocation(
                                _user,
                                context.locale.languageCode,
                              )!,
                              style:
                                  theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 14,
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.6),
                                  ) ??
                                  TextStyle(
                                    fontSize: 14,
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.6),
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
                      ],
                    ),
                  ),
                ),
              ),
              SliverPersistentHeader(
                delegate: _StickyTabBarDelegate(
                  TabBar(
                    controller: _tabController,
                    indicatorColor: theme.colorScheme.primary,
                    labelColor: theme.colorScheme.primary,
                    unselectedLabelColor: theme.colorScheme.onSurface
                        .withOpacity(0.6),
                    tabs: [
                      Tab(icon: Icon(Icons.grid_on, size: 24), text: 'Posts'),
                      Tab(
                        icon: Icon(Icons.bookmark_border, size: 24),
                        text: 'Saved',
                      ),
                    ],
                  ),
                  theme,
                ),
                pinned: true,
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              // Posts Tab
              _buildPostsGrid(),
              // Saved Posts Tab
              _buildSavedPostsGrid(),
            ],
          ),
        ),
      ),
    );
  }

  String? _localizedName(UserModel? user, String locale) {
    if (user == null) return null;
    switch (locale) {
      case 'hi':
        return (user.name_hi != null && user.name_hi!.isNotEmpty)
            ? user.name_hi
            : user.name_en;
      case 'kn':
        return (user.name_kn != null && user.name_kn!.isNotEmpty)
            ? user.name_kn
            : user.name_en;
      default:
        return user.name_en;
    }
  }

  String? _localizedBio(UserModel? user, String locale) {
    if (user == null) return null;
    switch (locale) {
      case 'hi':
        return user.bio_hi ?? user.bio_en;
      case 'kn':
        return user.bio_kn ?? user.bio_en;
      default:
        return user.bio_en;
    }
  }

  String? _localizedLocation(UserModel? user, String locale) {
    if (user == null) return null;
    String? raw;
    switch (locale) {
      case 'hi':
        raw = user.location_hi ?? user.location_en;
        break;
      case 'kn':
        raw = user.location_kn ?? user.location_en;
        break;
      default:
        raw = user.location_en;
    }
    return _cleanLocation(raw);
  }

  String? _cleanLocation(String? value) {
    if (value == null) return null;
    final v = value.trim();
    if (v.isEmpty) return null;
    final lower = v.toLowerCase();
    // Treat any form of unknown across locales as unavailable
    const unknowns = {'unknown', 'पता नहीं', 'ಗೊತ್ತಿಲ್ಲ'};
    if (unknowns.contains(lower) || unknowns.contains(v)) return null;
    // If value is suspiciously long, skip showing to avoid junk
    if (v.length > 80) return null;
    return v;
  }

  Widget _buildPostsGrid() {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: theme.colorScheme.primary),
      );
    }

    if (_error != null) {
      return Center(child: Text('${'error'.tr()}: $_error'));
    }

    if (_posts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.grid_on,
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
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
            child:
                post.imageUrl != null
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
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.3,
                              ),
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
    );
  }

  Widget _buildSavedPostsGrid() {
    final theme = Theme.of(context);

    // For now, show empty state since saved posts functionality isn't implemented yet
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No saved posts yet',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Posts you save will appear here',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final ThemeData theme;

  _StickyTabBarDelegate(this.tabBar, this.theme);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor.withOpacity(0.3),
            width: 0.5,
          ),
        ),
      ),
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}
