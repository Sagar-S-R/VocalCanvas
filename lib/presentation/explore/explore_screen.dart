import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../core/services/post_service.dart';
import '../../data/models/post.dart';

// Data model for each item in our grid. In a real app, this would be in its own file.
class ArtworkItem {
  final String imagePath;
  final String title;
  final String artist;

  ArtworkItem({
    required this.imagePath,
    required this.title,
    required this.artist,
  });
}

// List of all the content to display. This is placeholder data.
final List<ArtworkItem> items = [
  ArtworkItem(
    imagePath: 'assets/Mosaic_Art.jpeg',
    title: 'Cosmic Shards',
    artist: 'Priya Sharma',
  ),
  ArtworkItem(
    imagePath: 'assets/Glass.jpg',
    title: 'Molten Light',
    artist: 'Rohan Mehta',
  ),
  ArtworkItem(
    imagePath: 'assets/Wooden_Toys.jpeg',
    title: 'Forest Friends',
    artist: 'Anjali Verma',
  ),
  ArtworkItem(
    imagePath: 'assets/Ceramic.jpg',
    title: 'Earthly Bowls',
    artist: 'Vikram Singh',
  ),
  // Add more items to see the grid grow
  ArtworkItem(
    imagePath: 'assets/Mosaic_Art.jpeg',
    title: 'Galaxy in Blue',
    artist: 'Priya Sharma',
  ),
  ArtworkItem(
    imagePath: 'assets/Ceramic.jpg',
    title: 'Glazed Dreams',
    artist: 'Vikram Singh',
  ),
  ArtworkItem(
    imagePath: 'assets/Glass.jpg',
    title: 'Sun Catcher',
    artist: 'Rohan Mehta',
  ),
  ArtworkItem(
    imagePath: 'assets/Wooden_Toys.jpeg',
    title: 'Playful Shapes',
    artist: 'Anjali Verma',
  ),
];

class ExploreScreen extends StatelessWidget {
  final PostService _postService = PostService();
  ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder helps make the grid responsive to different screen sizes.
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        if (constraints.maxWidth > 1200) {
          crossAxisCount = 5;
        } else if (constraints.maxWidth > 800) {
          crossAxisCount = 4;
        } else {
          crossAxisCount = 2;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              StaggeredGrid.count(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children:
                    items.asMap().entries.map((entry) {
                      int index = entry.key;
                      ArtworkItem item = entry.value;
                      return StaggeredGridTile.count(
                        crossAxisCellCount:
                            (index % 5 == 0 || index % 5 == 3) ? 2 : 1,
                        mainAxisCellCount:
                            (index % 5 == 0 || index % 5 == 3) ? 2 : 1.5,
                        child: ArtworkCard(item: item),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 32),
              SizedBox(
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
            ],
          ),
        );
      },
    );
  }
}

// A reusable card widget for displaying each art piece.
// In a real app, this would be in 'lib/presentation/widgets/artwork_card.dart'.
class ArtworkCard extends StatelessWidget {
  final ArtworkItem item;

  const ArtworkCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(item.imagePath, fit: BoxFit.cover),

          // Gradient overlay for better text readability at the bottom.
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.6, 1.0],
              ),
            ),
          ),

          // Text Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Lora',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'by ${item.artist}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontFamily: 'Lora',
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
