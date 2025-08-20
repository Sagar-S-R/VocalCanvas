import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'dart:math';

import '../../core/services/post_service.dart';
import '../../data/models/post.dart';
import '../home/home_screen.dart'; // Import for PostDetailOverlay
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
  final _random = Random();

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
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            child: Row(
              children: [
                Text(
                  'explore'.tr(),
                  style:
                      theme.textTheme.headlineLarge?.copyWith(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Serif',
                      ) ??
                      const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Serif',
                      ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _refreshPosts,
                  icon: Icon(
                    Icons.refresh,
                    color:
                        theme.iconTheme.color ?? theme.colorScheme.onBackground,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child:
                _isLoading
                    ? Center(
                      child: CircularProgressIndicator(
                        color: theme.colorScheme.primary,
                      ),
                    )
                    : _error != null
                    ? Center(child: Text('Error: $_error'))
                    : _posts.isEmpty
                    ? const Center(child: Text('No posts yet.'))
                    : RefreshIndicator(
                      onRefresh: _refreshPosts,
                      child: MasonryGridView.count(
                        crossAxisCount: 4, // Changed to 4 columns
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _posts.length,
                        itemBuilder: (context, index) {
                          final post = _posts[index];
                          // More dynamic sizing
                          final height = (1 + _random.nextInt(3)) * 100.0;
                          return SizedBox(
                            height: height,
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
