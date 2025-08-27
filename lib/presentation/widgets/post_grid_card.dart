import 'package:flutter/material.dart';
import '../../data/models/post.dart';

class PostGridCard extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;

  const PostGridCard({
    super.key,
    required this.post,
    required this.onTap,
  });

  String _getTitleForLanguage(BuildContext context) {
    String langCode = Localizations.localeOf(context).languageCode;
    if (langCode == 'hi') {
      return post.title_hi.isNotEmpty ? post.title_hi : post.title_en;
    }
    if (langCode == 'kn') {
      return post.title_kn.isNotEmpty ? post.title_kn : post.title_en;
    }
    return post.title_en;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  color: theme.colorScheme.surfaceVariant,
                ),
                child: post.imageUrl != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.network(
                          post.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: theme.colorScheme.surfaceVariant,
                              child: Icon(
                                Icons.image_not_supported,
                                color: theme.colorScheme.onSurfaceVariant,
                                size: 32,
                              ),
                            );
                          },
                        ),
                      )
                    : Container(
                        color: theme.colorScheme.surfaceVariant,
                        child: Icon(
                          Icons.image,
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 32,
                        ),
                      ),
              ),
            ),
            // Content
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        _getTitleForLanguage(context),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.favorite,
                            size: 12,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${post.likes.length}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.comment,
                            size: 12,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${post.commentsCount}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontSize: 10,
                            ),
                          ),
                          if (post.audioUrl != null) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.volume_up,
                              size: 12,
                              color: theme.colorScheme.primary,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
