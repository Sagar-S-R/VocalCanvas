import 'package:flutter/material.dart';
import 'dart:ui'; // Needed for ImageFilter
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
        pageBuilder: (BuildContext context, _, __) => PostDetailOverlay(post: post),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0EBE3),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600), // Constrain width like Instagram
          child: StreamBuilder<List<Post>>(
            stream: _postService.getPostsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF002924)));
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
                  return HomePostCard(
                    post: post,
                    onTap: () => _showPostDetails(context, post),
                  );
                },
              );
            },
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 40.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post Header
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFF002924),
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF002924),
                          ),
                        ),
                        if (post.location?.isNotEmpty == true)
                          Text(
                            post.location!,
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Post Image
            if (post.imageUrl != null)
              ClipRRect(
                // No border radius here, the parent container handles it
                child: Image.network(
                  post.imageUrl!,
                  width: double.infinity,
                  height: 400,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 400,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.image_not_supported, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.favorite_border, color: Color(0xFF002924)),
                        onPressed: () { /* Like action */ },
                      ),
                      IconButton(
                        icon: const Icon(Icons.comment_outlined, color: Color(0xFF002924)),
                        onPressed: () { /* Comment action */ },
                      ),
                      IconButton(
                        icon: const Icon(Icons.volume_up_outlined, color: Color(0xFF002924)),
                        onPressed: () { /* Listen action */ },
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.bookmark_border, color: Color(0xFF002924)),
                    onPressed: () { /* Bookmark action */ },
                  ),
                ],
              ),
            ),
            // Caption
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
              child: Text(
                post.caption ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFF002924)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------
// 3. POST DETAIL OVERLAY
// -----------------------------------------------------------------
class PostDetailOverlay extends StatelessWidget {
  final Post post;
  const PostDetailOverlay({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.5),
        body: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Center(
            child: GestureDetector(
              onTap: () {}, // Prevents closing when tapping inside the detail view
              child: Container(
                margin: const EdgeInsets.all(40),
                constraints: const BoxConstraints(maxWidth: 800),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EBE3),
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
                            errorBuilder: (context, error, stackTrace) => const Center(
                              child: Icon(Icons.image_not_supported, size: 50),
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
                            Text(post.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF002924))),
                            const SizedBox(height: 8),
                            if (post.location?.isNotEmpty == true)
                              Text(post.location!, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                            const SizedBox(height: 8),
                            const Divider(),
                            const SizedBox(height: 8),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Text(
                                  post.content,
                                  style: const TextStyle(fontSize: 16, height: 1.5, color: Color(0xFF002924)),
                                ),
                              ),
                            ),
                            const Divider(),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(icon: const Icon(Icons.favorite_border), onPressed: () {}),
                                IconButton(icon: const Icon(Icons.comment_outlined), onPressed: () {}),
                                IconButton(icon: const Icon(Icons.volume_up_outlined), onPressed: () {}),
                              ],
                            )
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
    return Scaffold(
      backgroundColor: const Color(0xFFF0EBE3),
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
                        MaterialPageRoute(builder: (context) => const CreateScreen()),
                      );
                    },
                    backgroundColor: const Color(0xFF002924),
                    foregroundColor: Colors.white,
                    elevation: 8.0,
                    tooltip: 'Create Post',
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
                    color: Colors.black.withOpacity(0.2), // Darken the background
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
                color: const Color(0xFF002924),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
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
                        _buildNavItem(icon: Icons.home, label: 'Home', index: 0),
                        _buildNavItem(icon: Icons.explore, label: 'Explore', index: 1),
                        _buildNavItem(icon: Icons.search, label: 'Search', index: 2),
                        _buildNavItem(icon: Icons.museum, label: 'Exhibition', index: 3),
                        _buildNavItem(icon: Icons.person, label: 'Profile', index: 4),
                        _buildNavItem(icon: Icons.settings, label: 'Settings', index: 5),
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
        color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
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
            child: _isRailExtended
                ? Row(
                    children: <Widget>[
                      const SizedBox(width: 16),
                      Icon(
                        icon,
                        color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          label,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
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
                      color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                      size: 24,
                    ),
                  ),
          ),
        ),
      ));
  
  }
}

// NOTE: PostDetailView class is not included here as it wasn't in the request,
// but your code will need it for the onTap functionality to work.
