import 'package:flutter/material.dart';
import '../../data/models/post.dart';
import '../profile/profile_screen.dart';

class PostDetailScreen extends StatelessWidget {
  final Post post;
  final EdgeInsets? outerPadding;

  const PostDetailScreen({super.key, required this.post, this.outerPadding});

  String _getLocationForLanguage(BuildContext context) {
    String langCode = Localizations.localeOf(context).languageCode;
    if (langCode == 'hi') return post.location_hi ?? post.location_en ?? '';
    if (langCode == 'kn') return post.location_kn ?? post.location_en ?? '';
    return post.location_en ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Posts',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: outerPadding ?? const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 1.0,
                child:
                    post.imageUrl != null
                        ? Image.network(
                          post.imageUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        )
                        : Container(
                          color: theme.colorScheme.surface,
                          child: Center(
                            child: Icon(
                              Icons.image_outlined,
                              size: 64,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.3,
                              ),
                            ),
                          ),
                        ),
              ),
            ),
            const SizedBox(height: 16),

            // Post Title
            Text(
              (() {
                String langCode = Localizations.localeOf(context).languageCode;
                if (langCode == 'hi') return post.title_hi;
                if (langCode == 'kn') return post.title_kn;
                return post.title_en;
              })(),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),

            // Location
            if (_getLocationForLanguage(context).isNotEmpty &&
                _getLocationForLanguage(context) != 'Unknown')
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getLocationForLanguage(context),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),

            // Description
            Text(
              'About this artwork',
              style:
                  theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ) ??
                  TextStyle(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                    fontSize: 16,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _getFormattedDescription(
                (() {
                  String langCode =
                      Localizations.localeOf(context).languageCode;
                  if (langCode == 'hi') return post.content_hi;
                  if (langCode == 'kn') return post.content_kn;
                  return post.content_en;
                })(),
              ),
              style:
                  theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                    height: 1.5,
                  ) ??
                  TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                    height: 1.5,
                    fontSize: 14,
                  ),
            ),
            const SizedBox(height: 20),

            // Tags
            if (post.hashtags.isNotEmpty) ...[
              Text(
                'Tags',
                style:
                    theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ) ??
                    TextStyle(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                      fontSize: 16,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    post.hashtags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.colorScheme.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          tag,
                          style:
                              theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ) ??
                              TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                        ),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 20),
            ],

            // Post Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time_outlined,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(post.timestamp),
                    style:
                        theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ) ??
                        TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 14,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Visit Profile button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProfileScreen(userId: post.userId),
                    ),
                  );
                },
                icon: const Icon(Icons.person_outline),
                label: const Text('Visit Profile'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
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
