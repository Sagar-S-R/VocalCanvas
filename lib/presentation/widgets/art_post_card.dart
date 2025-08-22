import 'package:flutter/material.dart';
import '../../data/models/post.dart';

class ArtPostCard extends StatelessWidget {
  final Post post;
  final VoidCallback? onTap;

  const ArtPostCard({super.key, required this.post, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 400,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Background Image
              Positioned.fill(
                child:
                    post.imageUrl != null
                        ? Image.network(post.imageUrl!, fit: BoxFit.cover)
                        : Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF1A237E),
                                Color(0xFF3949AB),
                                Color(0xFF5C6BC0),
                              ],
                            ),
                          ),
                          child: CustomPaint(painter: MosaicPatternPainter()),
                        ),
              ),

              // Dark Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ),

              // Content
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Location chip
                      if ((() {
                        String langCode =
                            Localizations.localeOf(context).languageCode;
                        String? location;
                        if (langCode == 'hi') {
                          location = post.location_hi;
                        } else if (langCode == 'kn')
                          location = post.location_kn;
                        else
                          location = post.location_en;
                        return location != null &&
                            location.isNotEmpty &&
                            location != 'Unknown';
                      })())
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            (() {
                              String langCode =
                                  Localizations.localeOf(context).languageCode;
                              if (langCode == 'hi') return post.location_hi!;
                              if (langCode == 'kn') return post.location_kn!;
                              return post.location_en!;
                            })(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                      const Spacer(),

                      // Description/Content
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          _getShortDescription(
                            (() {
                              String langCode =
                                  Localizations.localeOf(context).languageCode;
                              if (langCode == 'hi') return post.content_hi;
                              if (langCode == 'kn') return post.content_kn;
                              return post.content_en;
                            })(),
                          ),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            height: 1.4,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Title
                      Text(
                        (() {
                          String langCode =
                              Localizations.localeOf(context).languageCode;
                          if (langCode == 'hi') return post.title_hi;
                          if (langCode == 'kn') return post.title_kn;
                          return post.title_en;
                        })(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 10),

                      // Hashtags
                      if (post.hashtags.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          children:
                              post.hashtags.take(3).map((tag) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    tag,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getShortDescription(String content) {
    // Extract first sentence or first 100 characters as short description
    final sentences = content.split('. ');
    if (sentences.isNotEmpty && sentences[0].length <= 150) {
      return sentences[0] + (sentences.length > 1 ? '.' : '');
    }
    return content.length <= 150 ? content : '${content.substring(0, 147)}...';
  }
}

// Custom painter for mosaic pattern when no image is provided
class MosaicPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Create a mosaic-like pattern
    for (int i = 0; i < 20; i++) {
      for (int j = 0; j < 20; j++) {
        final rect = Rect.fromLTWH(
          (size.width / 20) * i,
          (size.height / 20) * j,
          size.width / 20,
          size.height / 20,
        );

        // Random colors for mosaic effect
        final colors = [
          Colors.blue.shade900,
          Colors.blue.shade700,
          Colors.blue.shade500,
          Colors.indigo.shade800,
          Colors.indigo.shade600,
        ];
        paint.color = colors[(i + j) % colors.length].withOpacity(0.8);

        canvas.drawRect(rect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
