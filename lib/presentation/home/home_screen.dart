import 'package:flutter/material.dart';
import 'dart:ui'; // Needed for ImageFilter
import 'package:vocal_canvas/presentation/home/widgets/post_card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';

import '../explore/explore_screen.dart';
import '../search/search_screen.dart';
import '../create/create_screen.dart';
import '../exhibition/exhibition_screen.dart';
import '../settings/settings_screen.dart';
import '../../core/services/post_service.dart';
import '../../data/models/post.dart';
import '../profile/profile_screen.dart'; // Import ProfileScreen

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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
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
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: theme.colorScheme.primary,
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No posts to show.'));
                    }

                    final posts = snapshot.data!;
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 40.0),
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
    );
  }
}

// -----------------------------------------------------------------
// 2. WIDGET FOR A SINGLE POST ON THE HOME FEED
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
class PostDetailOverlay extends StatelessWidget {
  final Post post;
  const PostDetailOverlay({super.key, required this.post});

  String _getTitleForLanguage(BuildContext context) {
    String langCode = Localizations.localeOf(context).languageCode;
    if (langCode == 'hi') {
      return post.title_hi.isNotEmpty ? post.title_hi : post.title_en;
    }
    if (langCode == 'kn') {
      return post.title_kn.isNotEmpty ? post.title_kn : post.title_en;
    }
    return post.title_en;
  }

  String _getLocationForLanguage(BuildContext context) {
    String langCode = Localizations.localeOf(context).languageCode;
    if (langCode == 'hi') {
      return (post.location_hi?.isNotEmpty == true)
          ? post.location_hi!
          : (post.location_en ?? '');
    }
    if (langCode == 'kn') {
      return (post.location_kn?.isNotEmpty == true)
          ? post.location_kn!
          : (post.location_en ?? '');
    }
    return post.location_en ?? '';
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
                child: Row(
                  children: [
                    // Image
                    if (post.imageUrl != null)
                      Expanded(
                        flex: 2,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                          ),
                          child: Image.network(
                            post.imageUrl!,
                            fit: BoxFit.cover,
                            height: double.infinity,
                            errorBuilder:
                                (context, error, stackTrace) => const Center(
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
                            if (_getLocationForLanguage(context).isNotEmpty)
                              Text(
                                _getLocationForLanguage(context),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                ),
                              ),
                            const SizedBox(height: 8),
                            const Divider(),
                            const SizedBox(height: 8),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Text(
                                  (() {
                                    String langCode =
                                        Localizations.localeOf(
                                          context,
                                        ).languageCode;
                                    if (langCode == 'hi') {
                                      return post.content_hi;
                                    }
                                    if (langCode == 'kn') {
                                      return post.content_kn;
                                    }
                                    return post.content_en;
                                  })(),
                                  style:
                                      theme.textTheme.bodyLarge?.copyWith(
                                        fontSize: 16,
                                        height: 1.5,
                                      ) ??
                                      const TextStyle(
                                        fontSize: 16,
                                        height: 1.5,
                                      ),
                                ),
                              ),
                            ),
                            const Divider(),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.favorite_border),
                                  onPressed: () {},
                                ),
                                IconButton(
                                  icon: const Icon(Icons.comment_outlined),
                                  onPressed: () {},
                                ),
                                IconButton(
                                  icon: const Icon(Icons.volume_up_outlined),
                                  onPressed: () {},
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
    const ExploreScreen(),
    const SearchScreen(),
    const ExhibitionScreen(),
    const ProfileScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: <Widget>[
          // Main content area, with padding on the left to avoid the collapsed sidebar
          Padding(
            padding: const EdgeInsets.only(left: 72),
            child: Stack(
              children: [
                Center(child: _widgetOptions.elementAt(_selectedIndex)),
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
                    foregroundColor:
                        theme.floatingActionButtonTheme.foregroundColor ??
                        Colors.white,
                    elevation: 8.0,
                    tooltip: 'create_post'.tr(),
                    child: const Icon(Icons.add, size: 36),
                  ),
                ),
              ],
            ),
          ),

          // Blurred overlay that appears ONLY when the sidebar is extended
          if (_isRailExtended)
            Padding(
              padding: const EdgeInsets.only(left: 72.0),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isRailExtended = false; // Collapse the sidebar on tap
                  });
                },
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Container(
                    color: Colors.black.withOpacity(
                      0.2,
                    ), // Darken the background
                  ),
                ),
              ),
            ),

          // The sidebar itself, positioned on the far left. It overlays content when extended.
          MouseRegion(
            onEnter: (_) => setState(() => _isRailExtended = true),
            onExit: (_) => setState(() => _isRailExtended = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              width: _isRailExtended ? 250 : 72, // Animate width change
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
                  // Navigation Items
                  Expanded(
                    child: ListView(
                      children: [
                        _buildNavItem(
                          icon: Icons.home,
                          label: 'home'.tr(),
                          index: 0,
                        ),
                        _buildNavItem(
                          icon: Icons.explore,
                          label: 'explore'.tr(),
                          index: 1,
                        ),
                        _buildNavItem(
                          icon: Icons.search,
                          label: 'search'.tr(),
                          index: 2,
                        ),
                        _buildNavItem(
                          icon: Icons.museum,
                          label: 'exhibition'.tr(),
                          index: 3,
                        ),
                        _buildNavItem(
                          icon: Icons.person,
                          label: 'profile'.tr(),
                          index: 4,
                        ),
                        _buildNavItem(
                          icon: Icons.settings,
                          label: 'settings'.tr(),
                          index: 5,
                        ),
                      ],
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

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isSelected = _selectedIndex == index;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white.withOpacity(0.08) : Colors.transparent,
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
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.7),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            label,
                            style: TextStyle(
                              color:
                                  isSelected
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.7),
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
                                ? Colors.white
                                : Colors.white.withOpacity(0.7),
                        size: 24,
                      ),
                    ),
          ),
        ),
      ),
    );
  }
}

// NOTE: PostDetailView class is not included here as it wasn't in the request,
// but your code will need it for the onTap functionality to work.
