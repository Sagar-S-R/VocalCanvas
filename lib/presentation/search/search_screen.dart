import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../data/models/post.dart';
import '../../core/services/post_service.dart';
import '../home/home_screen.dart';
import '../widgets/post_grid_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final PostService _postService = PostService();
  final TextEditingController _searchController = TextEditingController();
  List<Post> _searchResults = [];
  List<Post> _allPosts = [];
  bool _isLoading = true;
  bool _hasSearched = false;
  String? _error;

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
    try {
      final posts = await _postService.getAllPosts();
      if (mounted) {
        setState(() {
          _allPosts = posts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshPosts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    await _loadAllPosts();
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


  void _openPostDetail(Post post) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder:
            (BuildContext context, _, __) => PostDetailOverlay(post: post),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final postsToShow = _hasSearched ? _searchResults : _allPosts;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // Header with search bar
          Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            child: Column(
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
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _searchPosts('');
                            },
                          )
                        : IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: _refreshPosts,
                          ),
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
                if (_hasSearched) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'search_results'.tr() + ' (${_searchResults.length})',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: theme.colorScheme.primary,
                    ),
                  )
                : _error != null
                    ? Center(child: Text('Error: $_error'))
                    : postsToShow.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _hasSearched ? Icons.search_off : Icons.post_add,
                                  size: 64,
                                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _hasSearched ? 'no_results_found'.tr() : 'no_posts_yet'.tr(),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              // Responsive columns: min 2, max 5
                              int columns = (constraints.maxWidth ~/ 220).clamp(2, 5);
                              double spacing = 12;
                              return RefreshIndicator(
                                onRefresh: _refreshPosts,
                                child: GridView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 8,
                                  ),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: columns,
                                    crossAxisSpacing: spacing,
                                    mainAxisSpacing: spacing,
                                    childAspectRatio: 1,
                                  ),
                                  itemCount: postsToShow.length,
                                  itemBuilder: (context, index) {
                                    final post = postsToShow[index];
                                    return PostGridCard(
                                      post: post,
                                      onTap: () => _openPostDetail(post),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

}
