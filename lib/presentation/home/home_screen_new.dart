import 'package:flutter/material.dart';
import 'dart:ui'; // Needed for ImageFilter
import '../explore/explore_screen.dart';
import '../search/search_screen.dart';
import '../create/create_screen.dart';
import '../exhibition/exhibition_screen.dart';
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
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          // Main content area is now padded to the left to create space for the collapsed sidebar.
          Padding(
            padding: const EdgeInsets.only(left: 70),
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
                  color: Colors.white.withOpacity(0.95),
                  border: Border(
                    right: BorderSide(
                      color: Colors.grey.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: NavigationRail(
                      extended: _isRailExtended,
                      backgroundColor: Colors.transparent,
                      selectedIndex: _selectedIndex,
                      onDestinationSelected: (int index) {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                      labelType: NavigationRailLabelType.none,
                      destinations: const <NavigationRailDestination>[
                        NavigationRailDestination(
                          icon: Icon(Icons.home),
                          selectedIcon: Icon(Icons.home),
                          label: Text('Home'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.explore),
                          selectedIcon: Icon(Icons.explore),
                          label: Text('Explore'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.search),
                          selectedIcon: Icon(Icons.search),
                          label: Text('Search'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.palette),
                          selectedIcon: Icon(Icons.palette),
                          label: Text('Exhibition'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.person),
                          selectedIcon: Icon(Icons.person),
                          label: Text('Profile'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Home desktop view with Firebase posts integration
class Desktop1 extends StatelessWidget {
  final PostService _postService = PostService();

  Desktop1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),
      body: Stack(
        children: [
          // Tree image positioned at the top-right corner
          Positioned(
            right: 20,
            top: 20,
            child: Image.asset(
              'assets/tree.png',
              width: 200,
              height: 150,
              fit: BoxFit.contain,
            ),
          ),
          // Main content
          Positioned(
            left: 50,
            right: 250,
            top: 200,
            bottom: 50,
            child: StreamBuilder<List<Post>>(
              stream: _postService.getPostsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'No posts available',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  );
                }
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: snapshot.data!.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 24),
                  itemBuilder: (context, index) {
                    final post = snapshot.data![index];
                    return Container(
                      width: 300,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                            color: Colors.black.withOpacity(0.1),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.content,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'By: ${post.userId}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Posted: ${post.timestamp.toLocal().toString().split(".")[0]}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
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
