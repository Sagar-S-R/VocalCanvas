import 'package:flutter/foundation.dart' show kIsWeb;
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
    final isMobile = !kIsWeb && MediaQuery.of(context).size.width < 600;
    final shouldExpandOnHover =
        kIsWeb || MediaQuery.of(context).size.width >= 900;

    final expanded = shouldExpandOnHover ? _isHovered : !isMobile;

    final bg =
        Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).primaryColor;
    final iconColor = Theme.of(context).iconTheme.color ?? Colors.white;
    final textColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white;

    Widget content = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: expanded ? 200 : 56,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children:
            items
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14.0),
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        Icon(item.icon, color: iconColor, size: 24),
                        if (expanded) ...[
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              item.label,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: textColor, fontSize: 16),
                            ),
                          ),
                        ] else ...[
                          // Compact: show tooltip on hover/long-press
                          const SizedBox.shrink(),
                        ],
                      ],
                    ),
                  ),
                )
                .toList(),
      ),
    );

    if (shouldExpandOnHover) {
      content = MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: content,
      );
    }

    return content;
  }
}

class _SidebarItem {
  final IconData icon;
  final String label;
  const _SidebarItem({required this.icon, required this.label});
}
