import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/post.dart';

class ExhibitionScreen extends StatelessWidget {
  const ExhibitionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final horizontalPadding = width > 800 ? 80.0 : 24.0;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          vertical: 40.0,
          horizontal: horizontalPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Responsive title
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: FittedBox(
                alignment: Alignment.centerLeft,
                fit: BoxFit.scaleDown,
                child: Text(
                  'exhibition_title'.tr(),
                  style: TextStyle(
                    color: theme.textTheme.headlineLarge?.color ?? Colors.black,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Lora',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'exhibition_subtitle'.tr(),
              style: TextStyle(
                color:
                    theme.textTheme.bodyMedium?.color?.withOpacity(0.8) ??
                    Colors.black54,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 40),

            // Top Posts Section
            _buildSectionHeader(context, 'Top Posts'),
            const SizedBox(height: 20),

            // Firestore Stream Builder
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('posts')
                      .orderBy('likes', descending: true)
                      .limit(10)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _buildErrorWidget(context, snapshot.error.toString());
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingWidget(context);
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyWidget(context);
                }

                // If Firestore can't order by the length of the 'likes' array,
                // sort on the client as a fallback. If you add a numeric
                // 'likesCount' field to documents you can order on the server
                // instead which is more efficient for large datasets.
                final docs = snapshot.data!.docs.toList();

                // Client-side score: likesCount + commentsCount
                docs.sort((a, b) {
                  final aData = a.data() as Map<String, dynamic>;
                  final bData = b.data() as Map<String, dynamic>;

                  final aLikesCount =
                      aData['likesCount'] is int
                          ? aData['likesCount'] as int
                          : (aData['likes'] is List
                              ? (aData['likes'] as List).length
                              : 0);
                  final bLikesCount =
                      bData['likesCount'] is int
                          ? bData['likesCount'] as int
                          : (bData['likes'] is List
                              ? (bData['likes'] as List).length
                              : 0);

                  final aComments =
                      (aData['commentsCount'] is int)
                          ? aData['commentsCount'] as int
                          : 0;
                  final bComments =
                      (bData['commentsCount'] is int)
                          ? bData['commentsCount'] as int
                          : 0;

                  final aScore = aLikesCount + aComments;
                  final bScore = bLikesCount + bComments;

                  return bScore.compareTo(aScore);
                });

                final posts =
                    docs.map((doc) => Post.fromFirestore(doc)).toList();

                // Swipable rotating wheel carousel
                return SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: _TopPostsWheel(posts: posts),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: TextStyle(
        color:
            theme.textTheme.titleMedium?.color ??
            theme.textTheme.bodyLarge?.color ??
            Colors.black87,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        fontFamily: 'Lora',
      ),
    );
  }

  // ignore: unused_element
  Widget _buildPostCard(BuildContext context, Post post, int rank) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isLargeScreen = width > 600;
    final locale = context.locale.languageCode;

    // Get localized content
    final title = _getLocalizedTitle(post, locale);
    final content = _getLocalizedContent(post, locale);
    final location = _getLocalizedLocation(post, locale);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => PostDetailScreen(post: post)),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 20.0),
        elevation: 0,
        color: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post Image
            if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: AspectRatio(
                      aspectRatio: isLargeScreen ? 16 / 9 : 4 / 3,
                      child: Image.network(
                        post.imageUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: theme.colorScheme.surface,
                            child: Icon(
                              Icons.image_not_supported,
                              size: 48,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.5,
                              ),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: theme.colorScheme.surface,
                            child: Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Rank badge
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getRankColor(rank).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '#$rank',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  // Audio indicator
                  if (post.audioUrl != null && post.audioUrl!.isNotEmpty)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.volume_up,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),

            // Post Content
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    style: TextStyle(
                      color:
                          theme.textTheme.headlineSmall?.color ?? Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Lora',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Content preview
                  if (content.isNotEmpty)
                    Text(
                      content,
                      style: TextStyle(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(
                          0.8,
                        ),
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 12),

                  // Location (if available)
                  if (location != null && location.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: theme.colorScheme.secondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          location,
                          style: TextStyle(
                            color: theme.colorScheme.secondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),

                  // Hashtags
                  if (post.hashtags.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children:
                          post.hashtags.take(3).map((hashtag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondary.withOpacity(
                                  0.1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '#$hashtag',
                                style: TextStyle(
                                  color: theme.colorScheme.secondary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  const SizedBox(height: 12),

                  // Bottom row with likes and comments
                  Row(
                    children: [
                      Icon(Icons.favorite, size: 16, color: Colors.red[400]),
                      const SizedBox(width: 4),
                      Text(
                        _formatCount(post.likes.length),
                        style: TextStyle(
                          color: theme.textTheme.bodyMedium?.color,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.comment_outlined,
                        size: 16,
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(
                          0.7,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatCount(post.commentsCount),
                        style: TextStyle(
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(
                            0.7,
                          ),
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatTimestamp(post.timestamp),
                        style: TextStyle(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(
                            0.6,
                          ),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingWidget(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: theme.colorScheme.secondary),
            const SizedBox(height: 16),
            Text(
              'Loading amazing posts...',
              style: TextStyle(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String error) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.headlineSmall?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Unable to load posts. Please try again later.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.image_outlined,
            size: 48,
            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No posts yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.headlineSmall?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to share your amazing artwork!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for localization
  String _getLocalizedTitle(Post post, String locale) {
    switch (locale) {
      case 'hi':
        return post.title_hi.isNotEmpty ? post.title_hi : post.title_en;
      case 'kn':
        return post.title_kn.isNotEmpty ? post.title_kn : post.title_en;
      default:
        return post.title_en;
    }
  }

  String _getLocalizedContent(Post post, String locale) {
    switch (locale) {
      case 'hi':
        return post.content_hi.isNotEmpty ? post.content_hi : post.content_en;
      case 'kn':
        return post.content_kn.isNotEmpty ? post.content_kn : post.content_en;
      default:
        return post.content_en;
    }
  }

  String? _getLocalizedLocation(Post post, String locale) {
    switch (locale) {
      case 'hi':
        return post.location_hi?.isNotEmpty == true
            ? post.location_hi
            : post.location_en;
      case 'kn':
        return post.location_kn?.isNotEmpty == true
            ? post.location_kn
            : post.location_en;
      default:
        return post.location_en;
    }
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return const Color(0xFF6366F1); // Indigo
    }
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Now';
    }
  }
}

class _TopPostsWheel extends StatefulWidget {
  final List<Post> posts;
  const _TopPostsWheel({required this.posts});

  @override
  State<_TopPostsWheel> createState() => _TopPostsWheelState();
}

class _TopPostsWheelState extends State<_TopPostsWheel> {
  late final PageController _controller;
  double _page = 0.0;
  int _lastHapticPage = -1;

  @override
  void initState() {
    super.initState();
    final initial = (widget.posts.isEmpty ? 0 : widget.posts.length * 1000);
    _controller = PageController(initialPage: initial, viewportFraction: 0.85);
    _page = initial.toDouble();
    _controller.addListener(() {
      setState(() {
        _page = _controller.page ?? _controller.initialPage.toDouble();
        // Light haptic on page snap changes (very subtle)
        final currentInt = _page.round();
        if (currentInt != _lastHapticPage) {
          _lastHapticPage = currentInt;
          HapticFeedback.selectionClick();
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.locale.languageCode;

    if (widget.posts.isEmpty) {
      return const SizedBox.shrink();
    }

    return ScrollConfiguration(
      behavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          ui.PointerDeviceKind.touch,
          ui.PointerDeviceKind.mouse,
          ui.PointerDeviceKind.trackpad,
          ui.PointerDeviceKind.stylus,
          ui.PointerDeviceKind.invertedStylus,
        },
      ),
      child: PageView.builder(
        controller: _controller,
        // Infinite-style loop by omitting itemCount; we still mod the index.
        itemBuilder: (context, index) {
          final realIndex = index % widget.posts.length;
          final post = widget.posts[realIndex];

          final delta = (index - _page);
          final clamped = delta.clamp(-1.0, 1.0);
          final rotation = clamped * 0.25; // radians ~14 degrees
          final scale = 1 - (clamped.abs() * 0.08);
          final translateY = clamped.abs() * 24.0; // subtle vertical arc

          final title = _localTitle(post, locale);
          final content = _localContent(post, locale);

          return Transform.translate(
            offset: Offset(0, translateY),
            child: Transform.rotate(
              angle: rotation,
              child: Transform.scale(
                scale: scale,
                child: _WheelPostCard(
                  post: post,
                  title: title,
                  caption: content,
                  rank: realIndex + 1,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _localTitle(Post post, String locale) {
    switch (locale) {
      case 'hi':
        return post.title_hi.isNotEmpty ? post.title_hi : post.title_en;
      case 'kn':
        return post.title_kn.isNotEmpty ? post.title_kn : post.title_en;
      default:
        return post.title_en;
    }
  }

  String _localContent(Post post, String locale) {
    switch (locale) {
      case 'hi':
        return post.content_hi.isNotEmpty ? post.content_hi : post.content_en;
      case 'kn':
        return post.content_kn.isNotEmpty ? post.content_kn : post.content_en;
      default:
        return post.content_en;
    }
  }
}

class _WheelPostCard extends StatelessWidget {
  final Post post;
  final String title;
  final String caption;
  final int rank;
  const _WheelPostCard({
    required this.post,
    required this.title,
    required this.caption,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => PostDetailScreen(post: post)),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Image background
            Positioned.fill(
              child: post.imageUrl != null && post.imageUrl!.isNotEmpty
                  ? Image.network(
                      post.imageUrl!,
                      fit: BoxFit.cover,
                    )
                  : Container(color: theme.colorScheme.surfaceVariant),
            ),

            // Rank badge top-left
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '#$rank',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ),

            // Gradient overlay bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.65),
                      Colors.black.withOpacity(0.0),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (caption.isNotEmpty)
                      Text(
                        caption,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.favorite, color: Colors.pinkAccent, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          _formatCountLocal(post.likes.length),
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.chat_bubble_outline, color: Colors.white70, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          _formatCountLocal(post.commentsCount),
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  String _formatCountLocal(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}

// Post Detail Screen
class PostDetailScreen extends StatefulWidget {
  final Post post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  bool isLiked = false;
  late List<String> currentLikes;
  late final AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  int _commentCount = 0;

  @override
  void initState() {
    super.initState();
    currentLikes = List.from(widget.post.likes);
    _commentCount = widget.post.commentsCount;
    _audioPlayer = AudioPlayer();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      isLiked = currentLikes.contains(uid);
    }
    // TODO: Check if current user has liked this post
    // isLiked = currentLikes.contains(currentUserId);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = context.locale.languageCode;

    // Get localized content
    final title = _getLocalizedTitle(widget.post, locale);
    final content = _getLocalizedContent(widget.post, locale);
    final caption = _getLocalizedCaption(widget.post, locale);
    final location = _getLocalizedLocation(widget.post, locale);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // App Bar with image
          if (widget.post.imageUrl != null && widget.post.imageUrl!.isNotEmpty)
            SliverAppBar(
              expandedHeight: 300,
              floating: false,
              pinned: true,
              backgroundColor: theme.appBarTheme.backgroundColor,
              foregroundColor: theme.appBarTheme.foregroundColor,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      widget.post.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: theme.colorScheme.surface,
                          child: Icon(
                            Icons.image_not_supported,
                            size: 64,
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        );
                      },
                    ),
                    // Audio play/pause overlay
                    if (widget.post.audioUrl != null && widget.post.audioUrl!.isNotEmpty)
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: _togglePlay,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Icon(
                              _isPlaying ? Icons.pause_circle_outline : Icons.play_circle_outline,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Lora',
                      color: theme.textTheme.headlineLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Engagement info
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.favorite,
                              size: 18,
                              color: Colors.red[400],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _formatCount(currentLikes.length),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.red[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.comment_outlined,
                              size: 18,
                              color: theme.colorScheme.secondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _formatCount(_commentCount),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: _openAddCommentSheet,
                        icon: const Icon(Icons.add_comment_outlined, size: 18),
                        label: const Text('Comment'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatTimestamp(widget.post.timestamp),
                        style: TextStyle(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(
                            0.6,
                          ),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Location
                  if (location != null && location.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: theme.colorScheme.secondary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          location,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Content
                  if (content.isNotEmpty) ...[
                    Text(
                      'Content',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.headlineSmall?.color,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      content,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Caption
                  if (caption != null && caption.isNotEmpty) ...[
                    Text(
                      'Caption',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.headlineSmall?.color,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      caption,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Hashtags
                  if (widget.post.hashtags.isNotEmpty) ...[
                    Text(
                      'Tags',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.headlineSmall?.color,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          widget.post.hashtags.map((hashtag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondary.withOpacity(
                                  0.1,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                '#$hashtag',
                                style: TextStyle(
                                  color: theme.colorScheme.secondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Like button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _toggleLike,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isLiked
                                ? Colors.red[400]
                                : theme.colorScheme.secondary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_outline,
                      ),
                      label: Text(
                        isLiked ? 'Liked' : 'Like this post',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleLike() async {
    final user = await _ensureUser();
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign-in failed. Please try again.')),
      );
      return;
    }

    final docRef = FirebaseFirestore.instance.collection('posts').doc(widget.post.id);
    await FirebaseFirestore.instance.runTransaction((txn) async {
      final snap = await txn.get(docRef);
      final data = snap.data() as Map<String, dynamic>;
      final likes = List<String>.from(data['likes'] ?? <String>[]);
      final liked = likes.contains(user.uid);
      if (liked) {
        likes.remove(user.uid);
        txn.update(docRef, {
          'likes': likes,
          'likesCount': (data['likesCount'] is int ? data['likesCount'] as int : likes.length + 1) - 1,
        });
      } else {
        likes.add(user.uid);
        txn.update(docRef, {
          'likes': likes,
          'likesCount': (data['likesCount'] is int ? data['likesCount'] as int : likes.length - 1) + 1,
        });
      }
      if (mounted) {
        setState(() {
          currentLikes = likes;
          isLiked = !liked;
        });
      }
    });
  }

  Future<User?> _ensureUser() async {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) return user;
    try {
      final cred = await FirebaseAuth.instance.signInAnonymously();
      return cred.user;
    } catch (_) {
      return null;
    }
  }

  void _openAddCommentSheet() {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add a comment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Write something... ',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final text = controller.text.trim();
                    if (text.isEmpty) return;
                    final user = await _ensureUser();
                    if (user == null) return;
                    final postRef = FirebaseFirestore.instance.collection('posts').doc(widget.post.id);
                    await postRef.collection('comments').add({
                      'text': text,
                      'userId': user.uid,
                      'timestamp': FieldValue.serverTimestamp(),
                    });
                    await postRef.update({'commentsCount': FieldValue.increment(1)});
                    if (mounted) {
                      setState(() => _commentCount += 1);
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Comment added')));
                    }
                  },
                  icon: const Icon(Icons.send),
                  label: const Text('Send'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _togglePlay() async {
    final url = widget.post.audioUrl;
    if (url == null || url.isEmpty) return;
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(UrlSource(url));
    }
  }

  // Helper methods for localization
  String _getLocalizedTitle(Post post, String locale) {
    switch (locale) {
      case 'hi':
        return post.title_hi.isNotEmpty ? post.title_hi : post.title_en;
      case 'kn':
        return post.title_kn.isNotEmpty ? post.title_kn : post.title_en;
      default:
        return post.title_en;
    }
  }

  String _getLocalizedContent(Post post, String locale) {
    switch (locale) {
      case 'hi':
        return post.content_hi.isNotEmpty ? post.content_hi : post.content_en;
      case 'kn':
        return post.content_kn.isNotEmpty ? post.content_kn : post.content_en;
      default:
        return post.content_en;
    }
  }

  String? _getLocalizedCaption(Post post, String locale) {
    switch (locale) {
      case 'hi':
        return post.caption_hi?.isNotEmpty == true
            ? post.caption_hi
            : post.caption_en;
      case 'kn':
        return post.caption_kn?.isNotEmpty == true
            ? post.caption_kn
            : post.caption_en;
      default:
        return post.caption_en;
    }
  }

  String? _getLocalizedLocation(Post post, String locale) {
    switch (locale) {
      case 'hi':
        return post.location_hi?.isNotEmpty == true
            ? post.location_hi
            : post.location_en;
      case 'kn':
        return post.location_kn?.isNotEmpty == true
            ? post.location_kn
            : post.location_en;
      default:
        return post.location_en;
    }
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Now';
    }
  }
}
