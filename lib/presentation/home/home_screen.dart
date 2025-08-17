import 'package:flutter/material.dart';
import 'dart:ui'; // Needed for ImageFilter
import '../explore/explore_screen.dart';
import '../search/search_screen.dart';
import '../create/create_screen.dart';
import '../exhibition/exhibition_screen.dart';

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
    const ExploreScreen(), // Explore
    const SearchScreen(), // Search
    const ExhibitionScreen(), // Exhibition
    const Center(child: Text('Profile Page', style: TextStyle(color: Colors.black))), // Profile
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          // Main content area is now padded to the left to create space for the collapsed sidebar.
          Padding(
            padding: const EdgeInsets.only(left: 70),
            child: Center(
              child: _widgetOptions.elementAt(_selectedIndex),
            ),
          ),

          // Animated overlay for dimming effect when sidebar is hovered.
          if (_isRailExtended)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
              child: Container(
                color: Colors.black.withOpacity(0.2),
              ),
            ),
          
          // The overlay sidebar.
          MouseRegion(
            onEnter: (_) => setState(() => _isRailExtended = true),
            onExit: (_) => setState(() => _isRailExtended = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: _isRailExtended ? 220 : 70, // Thinner sidebar, expands on hover
              height: double.infinity,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 0, 41, 36), // New Dark Teal color
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                  )
                ]
              ),
              child: Column(
                children: [
                  const Spacer(), // Pushes the icons down
                  // Custom squarish icon for Create
                  SidebarIcon(
                    icon: Icons.add,
                    label: 'Create',
                    isSelected: false, // '+' is a one-off action button
                    isExtended: _isRailExtended,
                    onTap: () {
                       Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CreateScreen()));
                    },
                  ),
                  const SizedBox(height: 20),
                  SidebarIcon(
                    icon: Icons.home_outlined,
                    label: 'Home',
                    isSelected: _selectedIndex == 0,
                    isExtended: _isRailExtended,
                    onTap: () => setState(() => _selectedIndex = 0),
                  ),
                  SidebarIcon(
                    icon: Icons.explore_outlined,
                    label: 'Explore',
                    isSelected: _selectedIndex == 1,
                    isExtended: _isRailExtended,
                    onTap: () => setState(() => _selectedIndex = 1),
                  ),
                   SidebarIcon(
                    icon: Icons.search,
                    label: 'Search',
                    isSelected: _selectedIndex == 2,
                    isExtended: _isRailExtended,
                    onTap: () => setState(() => _selectedIndex = 2),
                  ),
                   SidebarIcon(
                    icon: Icons.palette_outlined,
                    label: 'Exhibition',
                    isSelected: _selectedIndex == 3,
                    isExtended: _isRailExtended,
                    onTap: () => setState(() => _selectedIndex = 3),
                  ),
                   SidebarIcon(
                    icon: Icons.person_outline,
                    label: 'Profile',
                    isSelected: _selectedIndex == 4,
                    isExtended: _isRailExtended,
                    onTap: () => setState(() => _selectedIndex = 4),
                  ),
                  const Spacer(), // Pushes settings to the bottom
                   SidebarIcon(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    isSelected: false, // Settings is also a one-off action
                    isExtended: _isRailExtended,
                    onTap: () { /* TODO: Handle Settings */ },
                  ),
                   const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom widget for the squarish sidebar icons
class SidebarIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isExtended;
  final VoidCallback onTap;

  const SidebarIcon({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isExtended,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: isExtended ? 180 : 50,
          height: 50,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF0EBE3) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: isExtended ? MainAxisAlignment.start : MainAxisAlignment.center,
            children: [
              if (isExtended) const SizedBox(width: 12),
              Icon(
                icon,
                color: isSelected ? const Color.fromARGB(255, 0, 41, 36) : const Color(0xFFF0EBE3),
              ),
              if (isExtended) ...[
                const SizedBox(width: 20),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? const Color.fromARGB(255, 0, 41, 36) : const Color(0xFFF0EBE3),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}


// The original Desktop1 widget with the new color scheme and layout.
class Desktop1 extends StatelessWidget {
  const Desktop1({super.key});

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
                  decoration:
                      BoxDecoration(color: boxColor, borderRadius: BorderRadius.circular(12.0)),
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
                    side:
                        BorderSide(width: 2, color: Colors.white),
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
                  decoration:
                      BoxDecoration(color: boxColor, borderRadius: BorderRadius.circular(12.0)),
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
                    image:
                        AssetImage("assets/Wooden_Toys.jpeg"),
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
                    side:
                        BorderSide(width: 2, color: Colors.white),
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
              top: 534,
              child: HoverableCard(
                child: Container(
                  width: 508,
                  height: 449,
                  decoration:
                      BoxDecoration(color: boxColor, borderRadius: BorderRadius.circular(12.0)),
                ),
              ),
            ),
            Positioned(
              left: 989,
              top: 588,
              child: Container(
                width: 508,
                height: 205,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  image: DecorationImage(
                    image: AssetImage("assets/Ceramic.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 1010,
              top: 812,
              child: SizedBox(
                width: 445,
                child: Text(
                  'Each curve and glaze tells the story of earth transformed by human touch.',
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
              left: 1010,
              top: 884,
              child: Text(
                'Ceramic',
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
              left: 1298,
              top: 759,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    side:
                        BorderSide(width: 2, color: Colors.white),
                    borderRadius: BorderRadius.circular(42),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 125,
                      child: Text(
                        'Tumkur',
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
            // The "Glass" section with the new background color.
            Positioned(
              left: 667,
              top: 49,
              child: HoverableCard(
                child: Container(
                  width: 282,
                  height: 921,
                  decoration:
                      BoxDecoration(color: boxColor, borderRadius: BorderRadius.circular(12.0)),
                ),
              ),
            ),
            Positioned(
              left: 705,
              top: 709,
              child: SizedBox(
                width: 206,
                child: Text(
                  'Glass',
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
              left: 726,
              top: 633,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    side:
                        BorderSide(width: 2, color: Colors.white),
                    borderRadius: BorderRadius.circular(42),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Hampi',
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
              left: 695,
              top: 822,
              child: SizedBox(
                width: 249,
                height: 177,
                child: Text(
                  'Molten glass and fire are my tools, creating forms that freeze movement in light.',
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
              left: 701,
              top: 90,
              child: Container(
                width: 216,
                height: 520,
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
              left: 55,
              top: 113,
              child: HoverableCard(
                child: Container(
                  width: 575,
                  height: 198,
                  decoration:
                      BoxDecoration(color: boxColor, borderRadius: BorderRadius.circular(12.0)),
                ),
              ),
            ),
            Positioned(
              left: 80,
              top: 193,
              child: SizedBox(
                width: 541,
                height: 99,
                child: Text(
                  'Known as the “Toy Town” of Karnataka, it’s world-famous for its colorful, eco-friendly wooden toys crafted using traditional lacquerware techniques.',
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
              left: 80,
              top: 142,
              child: Text(
                'Channapatna',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontFamily: 'Lora',
                  fontWeight: FontWeight.w400,
                  height: 1.20,
                ),
              ),
            ),
            // The tree.png image is now on the far right.
            Positioned(
              right: 0, // Positioned to the far right
              top: 49,
              child: Container(
                width: 150, // Made it slimmer
                height: 921,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/tree.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// A new widget to handle the hover effect.
class HoverableCard extends StatefulWidget {
  final Widget child;
  const HoverableCard({super.key, required this.child});

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
      child: AnimatedScale(
        scale: _isHovered ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: widget.child,
      ),
    );
  }
}
