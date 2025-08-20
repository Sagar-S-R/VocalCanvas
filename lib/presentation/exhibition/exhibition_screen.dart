import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

// A simple data model for a leaderboard entry.
class Artisan {
  final String name;
  final String imageUrl;
  final String craft;
  final int rank;
  final List<String> badges;

  Artisan({
    required this.name,
    required this.imageUrl,
    required this.craft,
    required this.rank,
    this.badges = const [],
  });
}

// Placeholder data for the leaderboard.
final List<Artisan> topArtisans = [
  Artisan(
    name: 'Priya Sharma',
    imageUrl: 'assets/Mosaic_Art.jpeg',
    craft: 'Mosaic Art',
    rank: 1,
    badges: ['Trending Creator', 'Storyteller'],
  ),
  Artisan(
    name: 'Rohan Mehta',
    imageUrl: 'assets/Glass.jpg',
    craft: 'Glass Blower',
    rank: 2,
    badges: ['Community Choice'],
  ),
  Artisan(
    name: 'Anjali Verma',
    imageUrl: 'assets/Wooden_Toys.jpeg',
    craft: 'Woodcraft',
    rank: 3,
  ),
];

class ExhibitionScreen extends StatelessWidget {
  const ExhibitionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final horizontalPadding = width > 800 ? 80.0 : 24.0;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          vertical: 40.0,
          horizontal: horizontalPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Responsive title: allow it to wrap/scale to avoid overflow
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 900),
              child: FittedBox(
                alignment: Alignment.centerLeft,
                fit: BoxFit.scaleDown,
                child: Text(
                  'exhibition_title'.tr(),
                  style: TextStyle(
                    color: theme.textTheme.headlineLarge?.color ?? Colors.black,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Lora',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'exhibition_subtitle'.tr(),
              style: TextStyle(
                color:
                    theme.textTheme.bodyMedium?.color?.withOpacity(0.8) ??
                    Colors.black54,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 40),

            // Leaderboard Section
            _buildSectionHeader(context, 'weekly_leaderboard'.tr()),
            const SizedBox(height: 20),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: topArtisans.length,
              itemBuilder: (context, index) {
                return _buildLeaderboardTile(context, topArtisans[index]);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper for section headers
  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: TextStyle(
        color:
            theme.textTheme.titleMedium?.color ??
            theme.textTheme.bodyLarge?.color ??
            Colors.black87,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        fontFamily: 'Lora',
      ),
    );
  }

  // Helper for the leaderboard list tiles
  Widget _buildLeaderboardTile(BuildContext context, Artisan artisan) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 0,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Text(
              '#${artisan.rank}',
              style: TextStyle(
                color: theme.colorScheme.secondary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 20),
            CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage(artisan.imageUrl),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  artisan.name,
                  style: TextStyle(
                    color: theme.textTheme.bodyLarge?.color ?? Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  artisan.craft,
                  style: TextStyle(
                    color:
                        theme.textTheme.bodyMedium?.color?.withOpacity(0.8) ??
                        Colors.black54,
                  ),
                ),
              ],
            ),
            const Spacer(),
            if (artisan.badges.isNotEmpty)
              Row(
                children:
                    artisan.badges
                        .map((badge) => _buildBadgeChip(context, badge))
                        .toList(),
              ),
          ],
        ),
      ),
    );
  }

  // Helper for the badge chips
  Widget _buildBadgeChip(BuildContext context, String label) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(left: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: theme.colorScheme.secondary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
