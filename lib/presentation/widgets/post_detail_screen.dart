import 'package:flutter/material.dart';
import '../../data/models/post.dart';

class PostDetailScreen extends StatelessWidget {
  final Post post;

  const PostDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: theme.appBarTheme.backgroundColor,
            iconTheme: IconThemeData(color: theme.appBarTheme.foregroundColor),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Background Image
                  Positioned.fill(
                    child:
                        post.imageUrl != null
                            ? Image.network(post.imageUrl!, fit: BoxFit.cover)
                            : Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    theme.colorScheme.primary.withOpacity(0.8),
                                    theme.colorScheme.primary.withOpacity(0.6),
                                    theme.colorScheme.primary.withOpacity(0.4),
                                  ],
                                ),
                              ),
                            ),
                  ),
                  // Dark overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.6),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Content overlay
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (post.location != null &&
                            post.location!.isNotEmpty &&
                            post.location != 'Unknown')
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: theme.scaffoldBackgroundColor.withOpacity(
                                0.08,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: theme.scaffoldBackgroundColor
                                    .withOpacity(0.12),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              post.location!,
                              style:
                                  theme.textTheme.bodyMedium?.copyWith(
                                    color:
                                        theme.appBarTheme.foregroundColor ??
                                        theme.colorScheme.onBackground,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ) ??
                                  const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ),
                        const SizedBox(height: 20),
                        Text(
                          post.title,
                          style:
                              theme.textTheme.headlineLarge?.copyWith(
                                color:
                                    theme.appBarTheme.foregroundColor ??
                                    theme.colorScheme.onBackground,
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                height: 1.1,
                              ) ??
                              const TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                height: 1.1,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: theme.scaffoldBackgroundColor,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Full Description
                    Text(
                      'About this artwork',
                      style: TextStyle(
                        color:
                            theme.textTheme.titleLarge?.color ??
                            theme.appBarTheme.foregroundColor ??
                            Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _getFormattedDescription(post.content),
                      style: TextStyle(
                        color:
                            theme.textTheme.bodyLarge?.color?.withOpacity(
                              0.9,
                            ) ??
                            Colors.white70,
                        fontSize: 16,
                        height: 1.6,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Hashtags
                    if (post.hashtags.isNotEmpty) ...[
                      Text(
                        'Tags',
                        style: TextStyle(
                          color:
                              theme.textTheme.titleMedium?.color ??
                              theme.appBarTheme.foregroundColor ??
                              Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children:
                            post.hashtags.map((tag) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  tag,
                                  style: TextStyle(
                                    color:
                                        theme.appBarTheme.foregroundColor ??
                                        Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ],

                    const SizedBox(height: 30),

                    // Post info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                color: Colors.white70,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _formatDate(post.timestamp),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          if (post.location != null &&
                              post.location!.isNotEmpty &&
                              post.location != 'Unknown') ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.white70,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  post.location!,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getFormattedDescription(String content) {
    // Split content into sentences and format as 4 lines max
    final sentences = content.split('. ');
    final lines = <String>[];

    for (int i = 0; i < sentences.length && lines.length < 4; i++) {
      String sentence = sentences[i].trim();
      if (sentence.isNotEmpty) {
        if (i < sentences.length - 1 && !sentence.endsWith('.')) {
          sentence += '.';
        }
        lines.add(sentence);
      }
    }

    return lines.join(' ');
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}
