import 'package:flutter/material.dart';
import 'dart:ui'; // Needed for ImageFilter
import 'package:vocal_canvas/presentation/home/widgets/post_card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/post_service.dart';

import '../search/search_screen.dart';
import '../create/create_screen.dart';
import '../exhibition/exhibition_screen.dart';
import '../settings/settings_screen.dart';
import '../../data/models/post.dart';
import '../profile/profile_screen.dart'; // Import ProfileScreen
import '../widgets/bottom_navigation_bar.dart';

// -----------------------------------------------------------------
// 1. HOME SCREEN - INSTAGRAM-STYLE FEED
// -----------------------------------------------------------------
class HomeFeedScreen extends StatelessWidget {
  final PostService _postService = PostService();

  HomeFeedScreen({super.key});

  void _showPostDetails(BuildContext context, Post post) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder:
            (BuildContext context, _, __) => PostDetailOverlay(post: post),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Defined theme here
    final screenWidth = MediaQuery.of(context).size.width;
    final showTrees = screenWidth >= 700;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          if (showTrees) ...[
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Center(
                child: Opacity(
                  opacity: 0.5,
                  child: Image.asset(
                    'assets/tree3.png',
                    height: 700,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Center(
                child: Opacity(
                  opacity: 0.5,
                  child: Image.asset(
                    'assets/tree4.png',
                    height: 700,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
          Center(
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 600,
              ), // Constrain width like Instagram
              child: Column(
                children: [
                  Expanded(
                    child: StreamBuilder<List<Post>>(
                      stream: _postService.getPostsStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: theme.colorScheme.primary,
                            ),
                          );
                        }
                        if (snapshot.hasError) {
                          // Corrected the string interpolation syntax
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text('No posts to show.'));
                        }

                        final posts = snapshot.data!;
                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            vertical: 40.0,
                            horizontal: 16.0,
                          ),
                          itemCount: posts.length,
                          itemBuilder: (context, index) {
                            final post = posts[index];
                            return PostCard(
                              post: post,
                              onTap: () => _showPostDetails(context, post),
                            );
                          },
                        );
                      },
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
}

// -----------------------------------------------------------------
// 2. WIDGET FOR A SINGLE POST ON THE HOME FEED (This is likely redundant if PostCard is already defined elsewhere)
// -----------------------------------------------------------------
class HomePostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;

  const HomePostCard({super.key, required this.post, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return PostCard(post: post, onTap: onTap);
  }
}

// -----------------------------------------------------------------
// 3. POST DETAIL OVERLAY
// -----------------------------------------------------------------
class PostDetailOverlay extends StatefulWidget {
  final Post post;
  const PostDetailOverlay({super.key, required this.post});

  @override
  State<PostDetailOverlay> createState() => _PostDetailOverlayState();
}

class _PostDetailOverlayState extends State<PostDetailOverlay> {
  late final PostService _postService;
  late final AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _postService = PostService();
    _audioPlayer = AudioPlayer();
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _getTitleForLanguage(BuildContext context) {
    String langCode = Localizations.localeOf(context).languageCode;
    if (langCode == 'hi') {
      return widget.post.title_hi.isNotEmpty
          ? widget.post.title_hi
          : widget.post.title_en;
    }
    if (langCode == 'kn') {
      return widget.post.title_kn.isNotEmpty
          ? widget.post.title_kn
          : widget.post.title_en;
    }
    return widget.post.title_en;
  }

  String _getLocationForLanguage(BuildContext context) {
    String langCode = Localizations.localeOf(context).languageCode;
    if (langCode == 'hi') {
      return (widget.post.location_hi?.isNotEmpty == true)
          ? widget.post.location_hi!
          : (widget.post.location_en ?? '');
    }
    if (langCode == 'kn') {
      return (widget.post.location_kn?.isNotEmpty == true)
          ? widget.post.location_kn!
          : (widget.post.location_en ?? '');
    }
    return widget.post.location_en ?? '';
  }

  String _getContentForLanguage(BuildContext context) {
    String langCode = Localizations.localeOf(context).languageCode;
    if (langCode == 'hi') {
      return widget.post.content_hi.isNotEmpty
          ? widget.post.content_hi
          : widget.post.content_en;
    }
    if (langCode == 'kn') {
      return widget.post.content_kn.isNotEmpty
          ? widget.post.content_kn
          : widget.post.content_en;
    }
    return widget.post.content_en;
  }

  Future<void> _toggleLike() async {
    if (_currentUserId == null) return;
    await _postService.toggleLike(widget.post.id, _currentUserId!);
    if (mounted) setState(() {});
  }

  void _showComments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentsSheet(postId: widget.post.id),
    );
  }

  Future<void> _playAudio() async {
    final audioUrl = widget.post.audioUrl;
    if (audioUrl == null) return;
    if (_isPlaying) {
      await _audioPlayer.pause();
      setState(() => _isPlaying = false);
      return;
    }
    try {
      if (audioUrl.startsWith('data:audio')) {
        final base64Str = audioUrl.split(',').last;
        final bytes = base64Decode(base64Str);
        await _audioPlayer.play(BytesSource(bytes));
      } else {
        await _audioPlayer.play(UrlSource(audioUrl));
      }
      setState(() => _isPlaying = true);
    } catch (_) {
      setState(() => _isPlaying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.5),
        body: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Center(
            child: GestureDetector(
              onTap:
                  () {}, // Prevents closing when tapping inside the detail view
              child: Container(
                margin: const EdgeInsets.all(40),
                constraints: const BoxConstraints(maxWidth: 800),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isSmall = constraints.maxWidth < 800;

                    if (isSmall) {
                      // Mobile layout: Column with image on top, details below
                      return Column(
                        children: [
                          // Image
                          if (widget.post.imageUrl != null)
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                              child: Image.network(
                                widget.post.imageUrl!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 300,
                                errorBuilder:
                                    (context, error, stackTrace) => Container(
                                      height: 300,
                                      color: theme.colorScheme.surface,
                                      child: const Center(
                                        child: Icon(
                                          Icons.image_not_supported,
                                          size: 50,
                                        ),
                                      ),
                                    ),
                              ),
                            ),
                          // Details
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getTitleForLanguage(context),
                                    style:
                                        theme.textTheme.titleLarge?.copyWith(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ) ??
                                        const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  if (_getLocationForLanguage(
                                    context,
                                  ).isNotEmpty)
                                    Text(
                                      _getLocationForLanguage(context),
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: theme.colorScheme.primary,
                                          ),
                                    ),
                                  const SizedBox(height: 16),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: Text(
                                        _getContentForLanguage(context),
                                        style: theme.textTheme.bodyLarge,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.favorite,
                                          color:
                                              widget.post.likes.contains(
                                                    _currentUserId,
                                                  )
                                                  ? Colors.red
                                                  : theme.iconTheme.color,
                                        ),
                                        onPressed: _toggleLike,
                                      ),
                                      Text('${widget.post.likes.length}'),
                                      const SizedBox(width: 16),
                                      IconButton(
                                        icon: const Icon(Icons.comment),
                                        onPressed: () => _showComments(context),
                                      ),
                                      Text('${widget.post.commentsCount}'),
                                      const Spacer(),
                                      if (widget.post.audioUrl != null)
                                        IconButton(
                                          icon: Icon(
                                            _isPlaying
                                                ? Icons.pause
                                                : Icons.play_arrow,
                                          ),
                                          onPressed: _playAudio,
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder:
                                                (_) => ProfileScreen(
                                                  userId: widget.post.userId,
                                                ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.person_outline),
                                      label: const Text('Visit Profile'),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      // Desktop layout: Row with image on left, details on right
                      return Row(
                        children: [
                          // Image
                          if (widget.post.imageUrl != null)
                            Expanded(
                              flex: 2,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  bottomLeft: Radius.circular(20),
                                ),
                                child: Image.network(
                                  widget.post.imageUrl!,
                                  fit: BoxFit.cover,
                                  height: double.infinity,
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                          const Center(
                                            child: Icon(
                                              Icons.image_not_supported,
                                              size: 50,
                                            ),
                                          ),
                                ),
                              ),
                            ),
                          // Details
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getTitleForLanguage(context),
                                    style:
                                        theme.textTheme.titleLarge?.copyWith(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ) ??
                                        const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  if (_getLocationForLanguage(
                                    context,
                                  ).isNotEmpty)
                                    Text(
                                      _getLocationForLanguage(context),
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: theme.colorScheme.primary,
                                          ),
                                    ),
                                  const SizedBox(height: 16),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: Text(
                                        _getContentForLanguage(context),
                                        style: theme.textTheme.bodyLarge,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.favorite,
                                          color:
                                              widget.post.likes.contains(
                                                    _currentUserId,
                                                  )
                                                  ? Colors.red
                                                  : theme.iconTheme.color,
                                        ),
                                        onPressed: _toggleLike,
                                      ),
                                      Text('${widget.post.likes.length}'),
                                      const SizedBox(width: 16),
                                      IconButton(
                                        icon: const Icon(Icons.comment),
                                        onPressed: () => _showComments(context),
                                      ),
                                      Text('${widget.post.commentsCount}'),
                                      const Spacer(),
                                      if (widget.post.audioUrl != null)
                                        IconButton(
                                          icon: Icon(
                                            _isPlaying
                                                ? Icons.pause
                                                : Icons.play_arrow,
                                          ),
                                          onPressed: _playAudio,
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder:
                                                (_) => ProfileScreen(
                                                  userId: widget.post.userId,
                                                ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.person_outline),
                                      label: const Text('Visit Profile'),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------
// 4. MAIN SCAFFOLD WITH SIDEBAR LOGIC
// -----------------------------------------------------------------
class VocalCanvasHomePage extends StatefulWidget {
  const VocalCanvasHomePage({super.key});

  @override
  State<VocalCanvasHomePage> createState() => _VocalCanvasHomePageState();
}

class _VocalCanvasHomePageState extends State<VocalCanvasHomePage> {
  int _selectedIndex = 0;
  bool _isRailExtended = false;

  static final List<Widget> _widgetOptions = <Widget>[
    HomeFeedScreen(),
    const SearchScreen(),
    const ExhibitionScreen(),
    const ProfileScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double width = MediaQuery.of(context).size.width;
    final bool isSmall =
        width < 800; // Increased breakpoint for better mobile experience

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Column(
            children: [
              // Main content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: isSmall ? 0 : 72),
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        child: _widgetOptions.elementAt(_selectedIndex),
                      ),
                      if (!isSmall)
                        Positioned(
                          bottom: 40,
                          right: 40,
                          child: FloatingActionButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CreateScreen(),
                                ),
                              );
                            },
                            backgroundColor: theme.colorScheme.primary,
                            child: Icon(
                              Icons.add,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      // Profile floating button for mobile
                      if (isSmall)
                        Positioned(
                          top: 40,
                          right: 16,
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedIndex = 3),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    _selectedIndex == 3
                                        ? theme.colorScheme.primary.withOpacity(
                                          0.9,
                                        )
                                        : theme.colorScheme.surface.withOpacity(
                                          0.9,
                                        ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.shadowColor.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor:
                                        _selectedIndex == 3
                                            ? theme.colorScheme.onPrimary
                                            : theme.colorScheme.primary,
                                    child: Icon(
                                      Icons.person,
                                      size: 16,
                                      color:
                                          _selectedIndex == 3
                                              ? theme.colorScheme.primary
                                              : theme.colorScheme.onPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'profile'.tr(),
                                    style: TextStyle(
                                      color:
                                          _selectedIndex == 3
                                              ? theme.colorScheme.onPrimary
                                              : theme.colorScheme.onSurface,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
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

          // Blurred overlay when sidebar is extended on mobile
          if (isSmall && _isRailExtended)
            GestureDetector(
              onTap: () {
                setState(() {
                  _isRailExtended = false;
                });
              },
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(color: Colors.black.withOpacity(0.2)),
              ),
            ),

          // Desktop Sidebar
          if (!isSmall)
            MouseRegion(
              onEnter: (_) => setState(() => _isRailExtended = true),
              onExit: (_) => setState(() => _isRailExtended = false),
              child: _buildSidebarContainer(
                theme,
                expandedWidth: 250,
                collapsedWidth: 72,
              ),
            ),

          // Mobile sidebar (only when extended)
          if (isSmall && _isRailExtended)
            MouseRegion(
              onExit: (_) => setState(() => _isRailExtended = false),
              child: _buildSidebarContainer(
                theme,
                expandedWidth: 250,
                collapsedWidth: 0,
              ),
            ),
        ],
      ),

      // Bottom Navigation Bar for Mobile
      bottomNavigationBar:
          isSmall
              ? CustomBottomNavigationBar(
                selectedIndex: _selectedIndex,
                onItemTapped: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                onMoreTapped: () => setState(() => _isRailExtended = true),
              )
              : null,
    );
  }

  Widget _buildSidebarContainer(
    ThemeData theme, {
    required double expandedWidth,
    required double collapsedWidth,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: _isRailExtended ? expandedWidth : collapsedWidth,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(5, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Expanded(
            child: ListView(
              children: [
                _buildNavItem(icon: Icons.home, label: 'home'.tr(), index: 0),
                _buildNavItem(
                  icon: Icons.search,
                  label: 'search'.tr(),
                  index: 1,
                ),
                _buildNavItem(
                  icon: Icons.museum,
                  label: 'exhibition'.tr(),
                  index: 2,
                ),
                _buildNavItem(
                  icon: Icons.person,
                  label: 'profile'.tr(),
                  index: 3,
                ),
                _buildNavItem(
                  icon: Icons.settings,
                  label: 'settings'.tr(),
                  index: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isSelected = _selectedIndex == index;
    final theme = Theme.of(context); // Get theme for onPrimary color

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        // Using theme color for selected item background
        color:
            isSelected
                ? theme.colorScheme.onPrimary.withOpacity(0.08)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedIndex = index;
            });
          },
          child: SizedBox(
            height: 56,
            child:
                _isRailExtended
                    ? Row(
                      children: <Widget>[
                        const SizedBox(width: 16),
                        Icon(
                          icon,
                          color:
                              isSelected
                                  ? theme
                                      .colorScheme
                                      .onPrimary // Use onPrimary
                                  : theme.colorScheme.onPrimary.withOpacity(
                                    0.7,
                                  ),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            label,
                            style: TextStyle(
                              color:
                                  isSelected
                                      ? theme
                                          .colorScheme
                                          .onPrimary // Use onPrimary
                                      : theme.colorScheme.onPrimary.withOpacity(
                                        0.7,
                                      ),
                              fontWeight:
                                  isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    )
                    : Center(
                      child: Icon(
                        icon,
                        color:
                            isSelected
                                ? theme
                                    .colorScheme
                                    .onPrimary // Use onPrimary
                                : theme.colorScheme.onPrimary.withOpacity(0.7),
                        size: 24,
                      ),
                    ),
          ),
        ),
      ),
    );
  }
}
