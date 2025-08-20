import 'package:flutter/material.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  bool _isHovered = false;

  final List<_SidebarItem> items = [
    _SidebarItem(icon: Icons.home, label: 'Home'),
    _SidebarItem(icon: Icons.search, label: 'Search'),
    _SidebarItem(icon: Icons.settings, label: 'Settings'),
    _SidebarItem(icon: Icons.person, label: 'Profile'),
    _SidebarItem(icon: Icons.info, label: 'Info'),
  ];

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: _isHovered ? 180 : 60,
        decoration: BoxDecoration(
          color:
              Theme.of(context).appBarTheme.backgroundColor ??
              Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:
              items
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Row(
                        children: [
                          SizedBox(width: 16),
                          Icon(
                            item.icon,
                            color:
                                Theme.of(context).iconTheme.color ??
                                Colors.white,
                            size: 28,
                          ),
                          if (_isHovered) ...[
                            SizedBox(width: 16),
                            Text(
                              item.label,
                              style: TextStyle(
                                color:
                                    Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.color ??
                                    Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }
}

class _SidebarItem {
  final IconData icon;
  final String label;
  const _SidebarItem({required this.icon, required this.label});
}
