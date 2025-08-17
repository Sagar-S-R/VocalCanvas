import 'package:flutter/material.dart';
import 'dart:ui'; // Needed for ImageFilter
import '../explore/explore_screen.dart';
import '../search/search_screen.dart';
import '../create/create_screen.dart';
import '../exhibition/exhibition_screen.dart';
import '../settings/settings_screen.dart';
import '../../core/services/post_service.dart';
import '../../data/models/post.dart';

// This is the main page widget that includes the sidebar.
class VocalCanvasHomePage extends StatefulWidget {
  const VocalCanvasHomePage({super.key});

  @override
  State<VocalCanvasHomePage> createState() => _VocalCanvasHomePageState();
}

class _VocalCanvasHomePageState extends State<VocalCanvasHomePage> {
  int _selectedIndex = 0;
  bool _isRailExtended = false;

  static final List<Widget> _widgetOptions = <Widget>[
    Desktop1(), // Home
    ExploreScreen(), // Explore
    const SearchScreen(), // Search
    const ExhibitionScreen(), // Exhibition
    const Center(
      child: Text('Profile Page', style: TextStyle(color: Colors.black)),
    ), // Profile
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          // Blur effect when sidebar is extended
          if (_isRailExtended)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(color: Colors.black.withOpacity(0.2)),
              ),
            ),

          // Main content area
          AnimatedPadding(
            duration: const Duration(milliseconds: 250),
            padding: EdgeInsets.only(left: _isRailExtended ? 250 : 70),
            child: Center(child: _widgetOptions.elementAt(_selectedIndex)),
          ),

          // Sidebar
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            top: 0,
            bottom: 0,
            left: 0,
            width: _isRailExtended ? 250 : 70,
            child: MouseRegion(
              onEnter: (_) => setState(() => _isRailExtended = true),
              onExit: (_) => setState(() => _isRailExtended = false),
              child: Container(
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
                    // Logo
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.palette,
                            color: Colors.white,
                            size: 32,
                          ),
                          if (_isRailExtended)
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 12),
                                child: Text(
                                  'VocalCanvas',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Navigation Items
                    Expanded(
                      child: ListView(
                        children: [
                          _buildNavItem(
                            icon: Icons.home,
                            label: 'Home',
                            index: 0,
                            isSelected: _selectedIndex == 0,
                            isRailExtended: _isRailExtended,
                          ),
                          _buildNavItem(
                            icon: Icons.explore,
                            label: 'Explore',
                            index: 1,
                            isSelected: _selectedIndex == 1,
                            isRailExtended: _isRailExtended,
                          ),
                          _buildNavItem(
                            icon: Icons.search,
                            label: 'Search',
                            index: 2,
                            isSelected: _selectedIndex == 2,
                            isRailExtended: _isRailExtended,
                          ),
                          _buildNavItem(
                            icon: Icons.museum,
                            label: 'Exhibition',
                            index: 3,
                            isSelected: _selectedIndex == 3,
                            isRailExtended: _isRailExtended,
                          ),
                          _buildNavItem(
                            icon: Icons.person,
                            label: 'Profile',
                            index: 4,
                            isSelected: _selectedIndex == 4,
                            isRailExtended: _isRailExtended,
                          ),
                          _buildNavItem(
                            icon: Icons.settings,
                            label: 'Settings',
                            index: 5,
                            isSelected: _selectedIndex == 5,
                            isRailExtended: _isRailExtended,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Create Post Button
          Positioned(
            top: 40,
            right: 40,
            child: FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreateScreen()),
                );
              },
              backgroundColor: const Color.fromARGB(255, 0, 41, 36),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Create Post'),
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
    required bool isSelected,
    required bool isRailExtended,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
          size: 24,
        ),
        title:
            isRailExtended
                ? Text(
                  label,
                  style: TextStyle(
                    color:
                        isSelected
                            ? Colors.white
                            : Colors.white.withOpacity(0.7),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                )
                : null,
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        contentPadding: EdgeInsets.symmetric(
          horizontal: isRailExtended ? 16 : 24,
          vertical: 8,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class Desktop1 extends StatelessWidget {
  final PostService _postService = PostService();

  Desktop1({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(color: Color(0xFFF0EBE3)),
      child: Stack(
        children: [
          // Tree image in top-right corner for aesthetics
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                image: const DecorationImage(
                  image: AssetImage("assets/tree.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Welcome text
          Positioned(
            left: 60,
            top: 60,
            child: Text(
              'Good morning, User',
              style: TextStyle(
                color: Colors.black,
                fontSize: 48,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                letterSpacing: -0.50,
              ),
            ),
          ),
          // Posts feed
          Positioned(
            left: 60,
            top: 150,
            right: 60,
            bottom: 60,
            child: StreamBuilder<List<Post>>(
              stream: _postService.getPostsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Loading posts...',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, size: 64, color: Colors.red),
                        SizedBox(height: 16),
                        Text(
                          'Error: ${snapshot.error}',
                          style: TextStyle(color: Colors.red, fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Check Firebase configuration and rules',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.post_add, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No posts yet.',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 32,
                            fontFamily: 'Lora',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Create your first post to get started!',
                          style: TextStyle(
                            color: Colors.black38,
                            fontSize: 18,
                            fontFamily: 'Lora',
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount;
                    if (constraints.maxWidth > 1200) {
                      crossAxisCount = 3;
                    } else if (constraints.maxWidth > 800) {
                      crossAxisCount = 2;
                    } else {
                      crossAxisCount = 1;
                    }
                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 24,
                        mainAxisSpacing: 24,
                        childAspectRatio: 1.2,
                      ),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final post = snapshot.data![index];
                        return InkWell(
                          onTap: () {
                            // TODO: Implement detail view
                          },
                          child: Container(
                            padding: const EdgeInsets.all(24.0),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (post.imageUrl != null)
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.network(
                                        post.imageUrl!,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 16),
                                Text(
                                  post.content, // Using content as title for now
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'Lora',
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'By: ${post.userId}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Posted: ${post.timestamp.toLocal().toString().split(".")[0]}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white38,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
