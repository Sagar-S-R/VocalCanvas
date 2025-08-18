import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../core/services/post_service.dart';
import '../../data/models/post.dart';
import '../widgets/post_detail_screen.dart';
import 'widgets/explore_post_card.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final PostService _postService = PostService();
  List<Post> _posts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    try {
      final posts = await _postService.getAllPosts();
      if (mounted) {
        setState(() {
          _posts = posts;
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
    await _loadPosts();
  }

  void _openPostDetail(Post post) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PostDetailScreen(post: post)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0EBE3),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            child: Row(
              children: [
                const Text(
                  'Explore',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Serif', // Example of a serif font
                    color: Color(0xFF002924),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _refreshPosts,
                  icon: const Icon(Icons.refresh, color: Color(0xFF002924)),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child:
                _isLoading
                    ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF002924),
                      ),
                    )
                    : _error != null
                    ? Center(child: Text('Error: $_error'))
                    : _posts.isEmpty
                    ? const Center(child: Text('No posts yet.'))
                    : RefreshIndicator(
                      onRefresh: _refreshPosts,
                      child: MasonryGridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _posts.length,
                        itemBuilder: (context, index) {
                          final post = _posts[index];
                          // Example of varying cell sizes
                          final crossAxisCellCount = (index % 3 == 0) ? 2 : 1;
                          final mainAxisCellCount =
                              (index % 4 == 0)
                                  ? 1.5
                                  : ((index % 3 == 0) ? 1.2 : 1.8);

                          return StaggeredGridTile.count(
                            crossAxisCellCount: crossAxisCellCount,
                            mainAxisCellCount: mainAxisCellCount,
                            child: ExplorePostCard(
                              post: post,
                              onTap: () => _openPostDetail(post),
                            ),
                          );
                        },
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
