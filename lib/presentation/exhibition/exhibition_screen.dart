import 'package:flutter/material.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xFFF0EBE3),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 50.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'The Sunday Exhibition',
              style: TextStyle(
                color: Colors.black,
                fontSize: 48,
                fontWeight: FontWeight.bold,
                fontFamily: 'Lora',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Celebrating the most inspiring creators of the week.',
              style: TextStyle(color: Colors.black54, fontSize: 20),
            ),
            const SizedBox(height: 40),

            // Leaderboard Section
            _buildSectionHeader('Weekly Leaderboard'),
            const SizedBox(height: 20),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: topArtisans.length,
              itemBuilder: (context, index) {
                return _buildLeaderboardTile(topArtisans[index]);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper for section headers
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.black87,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        fontFamily: 'Lora',
      ),
    );
  }

  // Helper for the leaderboard list tiles
  Widget _buildLeaderboardTile(Artisan artisan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Text(
              '#${artisan.rank}',
              style: TextStyle(
                color: Colors.deepPurple.shade300,
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
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  artisan.craft,
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
            const Spacer(),
            if (artisan.badges.isNotEmpty)
              Row(
                children:
                    artisan.badges
                        .map((badge) => _buildBadgeChip(badge))
                        .toList(),
              ),
          ],
        ),
      ),
    );
  }

  // Helper for the badge chips
  Widget _buildBadgeChip(String label) {
    return Container(
      margin: const EdgeInsets.only(left: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.deepPurple.shade800,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
