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
  bool _isRailExtended = false; // To control the hover state of the entire rail

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
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
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
                    // Logo or App name
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
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
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 200),
                                opacity: _isRailExtended ? 1.0 : 0.0,
                                child: const Padding(
                                  padding: EdgeInsets.only(left: 12),
                                  child: Text(
                                    'VocalCanvas',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
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
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Floating Create Post Button
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
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
                ? AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isRailExtended ? 1.0 : 0.0,
                  child: Text(
                    label,
                    style: TextStyle(
                      color:
                          isSelected
                              ? Colors.white
                              : Colors.white.withOpacity(0.7),
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
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
    // New Dark Teal color for the boxes.
    const boxColor = Color.fromARGB(255, 0, 41, 36);

    return FittedBox(
      child: Container(
        width: 1700,
        height: 1024,
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(color: Color(0xFFF0EBE3)),
        child: Stack(
          children: [
            // All content boxes are updated to the new dark teal color and have rounded corners.
            Positioned(
              left: 49,
              top: 339,
              child: HoverableCard(
                child: Container(
                  width: 581,
                  height: 632,
                  decoration: BoxDecoration(
                    color: boxColor,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 42,
              top: 42,
              child: SizedBox(
                width: 563,
                height: 49,
                child: Text(
                  'Good morning, User',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 48,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    height: 0.73,
                    letterSpacing: -0.50,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 93,
              top: 376,
              child: Container(
                width: 495,
                height: 350,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  image: DecorationImage(
                    image: AssetImage("assets/Mosaic_Art.jpeg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 84,
              top: 861,
              child: SizedBox(
                width: 736,
                child: Text(
                  'Mosaic Art',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 80,
                    fontStyle: FontStyle.italic,
                    fontFamily: 'Lora',
                    fontWeight: FontWeight.w600,
                    height: 1.20,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 103,
              top: 682,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 2, color: Colors.white),
                    borderRadius: BorderRadius.circular(42),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Bengaluru',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontFamily: 'Lora',
                        fontWeight: FontWeight.w400,
                        height: 1.20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 85,
              top: 762,
              child: SizedBox(
                width: 498,
                height: 99,
                child: Text(
                  'Every shard tells a story—my mosaics transform broken pieces into living patterns of hope.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontFamily: 'Lora',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 989,
              top: 52,
              child: HoverableCard(
                child: Container(
                  width: 507,
                  height: 444,
                  decoration: BoxDecoration(
                    color: boxColor,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 988,
              top: 98,
              child: Container(
                width: 508,
                height: 205,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  image: DecorationImage(
                    image: AssetImage("assets/Wooden_Toys.jpeg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 1010,
              top: 338,
              child: SizedBox(
                width: 441,
                child: Text(
                  'My toys are made to spark imagination—not batteries.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontFamily: 'Lora',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 1006,
              top: 400,
              child: Text(
                'Wooden Toys',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 80,
                  fontStyle: FontStyle.italic,
                  fontFamily: 'Lora',
                  fontWeight: FontWeight.w600,
                  height: 1.20,
                ),
              ),
            ),
            Positioned(
              left: 1247,
              top: 95,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 2, color: Colors.white),
                    borderRadius: BorderRadius.circular(42),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 176,
                      child: Text(
                        'Mangaluru',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontFamily: 'Lora',
                          fontWeight: FontWeight.w400,
                          height: 1.20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 989,
              top: 608,
              child: HoverableCard(
                child: Container(
                  width: 507,
                  height: 363,
                  decoration: BoxDecoration(
                    color: boxColor,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 1022,
              top: 656,
              child: Container(
                width: 443,
                height: 183,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  image: DecorationImage(
                    image: AssetImage("assets/Glass.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 1081,
              top: 676,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 2, color: Colors.white),
                    borderRadius: BorderRadius.circular(42),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 104,
                      child: Text(
                        'Delhi',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontFamily: 'Lora',
                          fontWeight: FontWeight.w400,
                          height: 1.20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 1022,
              top: 892,
              child: SizedBox(
                width: 304,
                height: 37,
                child: Text(
                  'Capturing light in glass.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontFamily: 'Lora',
                    fontWeight: FontWeight.w400,
                    height: 1.20,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 1022,
              top: 846,
              child: SizedBox(
                width: 386,
                height: 46,
                child: Text(
                  'Glass Art',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 80,
                    fontStyle: FontStyle.italic,
                    fontFamily: 'Lora',
                    fontWeight: FontWeight.w600,
                    height: 0.58,
                  ),
                ),
              ),
            ),
            // Firestore posts feed at the bottom
            Positioned(
              left: 49,
              bottom: 20,
              child: SizedBox(
                width: 1600,
                height: 250,
                child: StreamBuilder<List<Post>>(
                  stream: _postService.getPostsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          'No posts yet.',
                          style: TextStyle(color: Colors.black, fontSize: 24),
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
                          width: 400,
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
                              Text(
                                post.content,
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontFamily: 'Lora',
                                ),
                              ),
                              const SizedBox(height: 16),
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
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HoverableCard extends StatefulWidget {
  final Widget child;
  const HoverableCard({required this.child, super.key});

  @override
  State<HoverableCard> createState() => _HoverableCardState();
}

class _HoverableCardState extends State<HoverableCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform:
            Matrix4.identity()
              ..scale(_isHovered ? 1.02 : 1.0)
              ..translate(0.0, _isHovered ? -5.0 : 0.0),
        child: widget.child,
      ),
    );
  }
}
