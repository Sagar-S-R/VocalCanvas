import 'package:flutter/material.dart';
import 'dart:ui'; // Needed for ImageFilter
import '../explore/explore_screen.dart';
import '../search/search_screen.dart';
import '../create/create_screen.dart';
import '../exhibition/exhibition_screen.dart';
import '../settings/settings_screen.dart';
import '../../core/services/post_service.dart';
import '../../data/models/post.dart';

// -----------------------------------------------------------------
// 1. HOME SCREEN WIDGET (NOW FETCHES FROM FIREBASE)
// -----------------------------------------------------------------
class FirebasePostFeed extends StatelessWidget {
  final PostService _postService = PostService();

  FirebasePostFeed({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0EBE3),
      body: Stack(
        children: [
          // Tree image occupying the right side border
          Positioned(
            top: 0,
            right: 0,
            bottom: 0,
            child: Container(
              width: 150, // Width of the tree image area
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/tree.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Main content area with posts
          Padding(
            padding: const EdgeInsets.fromLTRB(
              60,
              60,
              190,
              60,
            ), // L, T, R, B padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Text
                const Text(
                  'Good morning, User',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 48,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                // Expanded area for the post grid
                Expanded(
                  child: StreamBuilder<List<Post>>(
                    stream: _postService.getPostsStream(),
                    builder: (context, snapshot) {
                      // --- Loading State ---
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      // --- Error State ---
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      // --- No Data State ---
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No posts yet.'));
                      }
                      // --- Data Loaded State ---
                      final posts = snapshot.data!;
                      return GridView.builder(
                        padding: const EdgeInsets.only(top: 20),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3, // Adjust number of columns
                              crossAxisSpacing: 24,
                              mainAxisSpacing: 24,
                              childAspectRatio: 0.9,
                            ),
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final post = posts[index];
                          // This is the container for each post "box"
                          return Container(
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 0, 41, 36),
                              borderRadius: BorderRadius.circular(12.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: PostGridItem(post: post),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------
// 2. WIDGET FOR A SINGLE POST ITEM IN THE GRID
// -----------------------------------------------------------------
class PostGridItem extends StatelessWidget {
  final Post post;
  const PostGridItem({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image takes up most of the space
          if (post.imageUrl != null)
            Expanded(
              child: Image.network(
                post.imageUrl!,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) => const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.white54,
                      ),
                    ),
              ),
            ),
          // Text content at the bottom
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'By: ${post.userId}',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------
// 3. MAIN SCAFFOLD WITH THE FIXED SIDEBAR & UPDATED FAB
// -----------------------------------------------------------------
class VocalCanvasHomePage extends StatefulWidget {
  const VocalCanvasHomePage({super.key});

  @override
  State<VocalCanvasHomePage> createState() => _VocalCanvasHomePageState();
}

class _VocalCanvasHomePageState extends State<VocalCanvasHomePage> {
  int _selectedIndex = 0;
  bool _isRailExtended = false;

  // Updated widget options
  static final List<Widget> _widgetOptions = <Widget>[
    FirebasePostFeed(), // Home
    ExploreScreen(),
    const SearchScreen(),
    const ExhibitionScreen(),
    const Center(child: Text('Profile Page')),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          // Main Content Area
          Center(child: _widgetOptions.elementAt(_selectedIndex)),

          // Blurred Overlay when rail is extended
          if (_isRailExtended)
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

          // Sidebar
          MouseRegion(
            onEnter: (_) => setState(() => _isRailExtended = true),
            onExit: (_) => setState(() => _isRailExtended = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              width: _isRailExtended ? 250 : 70,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 0, 41, 36),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
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
                          label: 'Home',
                          index: 0,
                        ),
                        _buildNavItem(
                          icon: Icons.explore,
                          label: 'Explore',
                          index: 1,
                        ),
                        _buildNavItem(
                          icon: Icons.search,
                          label: 'Search',
                          index: 2,
                        ),
                        _buildNavItem(
                          icon: Icons.museum,
                          label: 'Exhibition',
                          index: 3,
                        ),
                        _buildNavItem(
                          icon: Icons.person,
                          label: 'Profile',
                          index: 4,
                        ),
                        _buildNavItem(
                          icon: Icons.settings,
                          label: 'Settings',
                          index: 5,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // UPDATED "Create Post" FAB
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
              backgroundColor: const Color.fromARGB(255, 0, 41, 36),
              foregroundColor: Colors.white,
              elevation: 8.0,
              tooltip: 'Create Post',
              child: const Icon(Icons.add, size: 36),
            ),
          ),
        ],
      ),
    );
  }

  // DEFINITIVELY FIXED NAVIGATION ITEM WIDGET
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
            child:
                _isRailExtended
                    // Use a Row ONLY when expanded
                    ? Row(
                      children: <Widget>[
                        const SizedBox(width: 16), // Left padding
                        Icon(
                          icon,
                          color:
                              isSelected
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.7),
                          size: 24,
                        ),
                        const SizedBox(
                          width: 12,
                        ), // Space between icon and text
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
                    // Use a simple Center when collapsed to prevent overflow
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
