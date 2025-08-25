import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/post.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Post> _searchResults = [];
  List<Post> _allPosts = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _loadAllPosts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllPosts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance
              .collection('posts')
              .orderBy('timestamp', descending: true)
              .get();

      final List<Post> posts =
          snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList();

      setState(() {
        _allPosts = posts;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading posts: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _searchPosts(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _hasSearched = false;
      });
      return;
    }

    setState(() {
      _hasSearched = true;
      _isLoading = true;
    });

    // Get current locale for appropriate language search
    final locale = context.locale.languageCode;
    final searchQuery = query.toLowerCase().trim();

    final List<Post> results =
        _allPosts.where((post) {
          // Search in title based on current locale
          String title = '';
          switch (locale) {
            case 'hi':
              title = post.title_hi.toLowerCase();
              break;
            case 'kn':
              title = post.title_kn.toLowerCase();
              break;
            default:
              title = post.title_en.toLowerCase();
          }

          // Search in content based on current locale
          String content = '';
          switch (locale) {
            case 'hi':
              content = post.content_hi.toLowerCase();
              break;
            case 'kn':
              content = post.content_kn.toLowerCase();
              break;
            default:
              content = post.content_en.toLowerCase();
          }

          // Search in location based on current locale
          String location = '';
          switch (locale) {
            case 'hi':
              location = (post.location_hi ?? '').toLowerCase();
              break;
            case 'kn':
              location = (post.location_kn ?? '').toLowerCase();
              break;
            default:
              location = (post.location_en ?? '').toLowerCase();
          }

          // Search in hashtags
          final hashtagMatch = post.hashtags.any(
            (hashtag) => hashtag.toLowerCase().contains(searchQuery),
          );

          return title.contains(searchQuery) ||
              content.contains(searchQuery) ||
              location.contains(searchQuery) ||
              hashtagMatch;
        }).toList();

    setState(() {
      _searchResults = results;
      _isLoading = false;
    });
  }

  String _getCurrentTitle(Post post) {
    final locale = context.locale.languageCode;
    switch (locale) {
      case 'hi':
        return post.title_hi.isNotEmpty ? post.title_hi : post.title_en;
      case 'kn':
        return post.title_kn.isNotEmpty ? post.title_kn : post.title_en;
      default:
        return post.title_en;
    }
  }

  String _getCurrentContent(Post post) {
    final locale = context.locale.languageCode;
    switch (locale) {
      case 'hi':
        return post.content_hi.isNotEmpty ? post.content_hi : post.content_en;
      case 'kn':
        return post.content_kn.isNotEmpty ? post.content_kn : post.content_en;
      default:
        return post.content_en;
    }
  }

  String? _getCurrentLocation(Post post) {
    final locale = context.locale.languageCode;
    switch (locale) {
      case 'hi':
        return post.location_hi?.isNotEmpty == true
            ? post.location_hi
            : post.location_en;
      case 'kn':
        return post.location_kn?.isNotEmpty == true
            ? post.location_kn
            : post.location_en;
      default:
        return post.location_en;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            TextField(
              controller: _searchController,
              onChanged: _searchPosts,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: 18,
                color: theme.colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'search_posts'.tr(),
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                prefixIcon: Icon(Icons.search, color: theme.iconTheme.color),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _searchPosts('');
                          },
                        )
                        : null,
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 20.0,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Loading indicator
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              )
            // Search results
            else if (_hasSearched) ...[
              Text(
                'search_results'.tr() + ' (${_searchResults.length})',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (_searchResults.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: theme.colorScheme.onSurface.withOpacity(0.4),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'no_results_found'.tr(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    return _buildPostCard(_searchResults[index]);
                  },
                ),
            ]
            // Recent posts when no search
            else ...[
              Text(
                'recent_posts'.tr(),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (_allPosts.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text('No posts available'),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _allPosts.length > 10 ? 10 : _allPosts.length,
                  itemBuilder: (context, index) {
                    return _buildPostCard(_allPosts[index]);
                  },
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(Post post) {
    final theme = Theme.of(context);
    final currentTitle = _getCurrentTitle(post);
    final currentContent = _getCurrentContent(post);
    final currentLocation = _getCurrentLocation(post);

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post header with title and timestamp
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    currentTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                Text(
                  DateFormat.yMMMd().format(post.timestamp),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Location if available
            if (currentLocation != null && currentLocation.isNotEmpty) ...[
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    currentLocation,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            // Post content
            Text(
              currentContent,
              style: theme.textTheme.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // Image if available
            if (post.imageUrl != null && post.imageUrl!.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  post.imageUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: theme.colorScheme.surface,
                      child: const Center(child: Icon(Icons.broken_image)),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Hashtags
            if (post.hashtags.isNotEmpty) ...[
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children:
                    post.hashtags.map((hashtag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '#$hashtag',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 12),
            ],

            // Post stats
            Row(
              children: [
                Icon(Icons.favorite, size: 16, color: Colors.red),
                const SizedBox(width: 4),
                Text('${post.likes.length}', style: theme.textTheme.bodySmall),
                const SizedBox(width: 16),
                Icon(
                  Icons.comment,
                  size: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text('${post.commentsCount}', style: theme.textTheme.bodySmall),
                const Spacer(),
                if (post.audioUrl != null && post.audioUrl!.isNotEmpty)
                  Icon(
                    Icons.audiotrack,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
