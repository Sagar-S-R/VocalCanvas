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

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  final PostService _postService = PostService();
  final String _userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  UserModel? _user;
  List<Post> _posts = [];
  bool _isLoading = true;
  String? _error;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  late TabController _tabController;

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
                        
                        // Name (multilingual)
                        Text(
                          _localizedName(_user, context.locale.languageCode) ?? 'Art Lover',
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
                        
                        // Bio/Intro paragraph (multilingual)
                        if (_localizedBio(_user, context.locale.languageCode) != null &&
                            _localizedBio(_user, context.locale.languageCode)!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              _localizedBio(_user, context.locale.languageCode)!,
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
                        
                        // Location (multilingual) if available
                        if (_localizedLocation(_user, context.locale.languageCode) != null &&
                            _localizedLocation(_user, context.locale.languageCode)!.isNotEmpty &&
                            _localizedLocation(_user, context.locale.languageCode)!.toLowerCase() != 'unknown')
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              _localizedLocation(_user, context.locale.languageCode)!,
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
                ),
              ),
              SliverPersistentHeader(
                delegate: _StickyTabBarDelegate(
                  TabBar(
                    controller: _tabController,
                    indicatorColor: theme.colorScheme.primary,
                    labelColor: theme.colorScheme.primary,
                    unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
                    tabs: [
                      Tab(
                        icon: Icon(
                          Icons.grid_on,
                          size: 24,
                        ),
                        text: 'Posts',
                      ),
                      Tab(
                        icon: Icon(
                          Icons.bookmark_border,
                          size: 24,
                        ),
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
        return (user.name_hi != null && user.name_hi!.isNotEmpty) ? user.name_hi : user.name_en;
      case 'kn':
        return (user.name_kn != null && user.name_kn!.isNotEmpty) ? user.name_kn : user.name_en;
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
    switch (locale) {
      case 'hi':
        return user.location_hi ?? user.location_en;
      case 'kn':
        return user.location_kn ?? user.location_en;
      default:
        return user.location_en;
    }
  }

  Widget _buildPostsGrid() {
    final theme = Theme.of(context);
    
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: theme.colorScheme.primary,
        ),
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
      BuildContext context, double shrinkOffset, bool overlapsContent) {
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
