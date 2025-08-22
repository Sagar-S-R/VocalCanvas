import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vocal_canvas/core/services/post_service.dart';
import 'package:vocal_canvas/data/models/post.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final VoidCallback onTap;

  const PostCard({super.key, required this.post, required this.onTap});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final PostService _postService = PostService();
  final String _currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  void _toggleLike() {
    _postService.toggleLike(widget.post.id, _currentUserId);
  }

  void _showComments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentsSheet(postId: widget.post.id),
    );
  }

  Future<void> _playAudio() async {
    if (widget.post.audioUrl != null) {
      if (_isPlaying) {
        await _audioPlayer.pause();
        setState(() => _isPlaying = false);
      } else {
        final audioUrl = widget.post.audioUrl!;
        if (audioUrl.startsWith('data:audio')) {
          // Extract base64 string
          final base64Str = audioUrl.split(',').last;
          try {
            final bytes = base64Decode(base64Str);
            await _audioPlayer.play(BytesSource(bytes));
            setState(() => _isPlaying = true);
          } catch (e) {
            print('Audio playback error: $e');
          }
        } else {
          await _audioPlayer.play(UrlSource(audioUrl));
          setState(() => _isPlaying = true);
        }
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isLiked = widget.post.likes.contains(_currentUserId);
    final theme = Theme.of(context);
    String langCode = Localizations.localeOf(context).languageCode;
    String postContent = widget.post.content_en;
    if (langCode == 'hi') {
      postContent = widget.post.content_hi;
    } else if (langCode == 'kn') {
      postContent = widget.post.content_kn;
    }
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 40.0),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post Header
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.primary,
                    child: Icon(
                      Icons.person,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (() {
                            String langCode =
                                Localizations.localeOf(context).languageCode;
                            if (langCode == 'hi') return widget.post.title_hi;
                            if (langCode == 'kn') return widget.post.title_kn;
                            return widget.post.title_en;
                          })(),
                          style: (theme.textTheme.titleMedium ??
                                  const TextStyle())
                              .copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: theme.colorScheme.onSurface,
                              ),
                        ),
                        if ((() {
                          String langCode =
                              Localizations.localeOf(context).languageCode;
                          String? location;
                          if (langCode == 'hi') {
                            location = widget.post.location_hi;
                          } else if (langCode == 'kn')
                            location = widget.post.location_kn;
                          else
                            location = widget.post.location_en;
                          return location?.isNotEmpty == true;
                        })())
                          Text(
                            (() {
                              String langCode =
                                  Localizations.localeOf(context).languageCode;
                              if (langCode == 'hi') {
                                return widget.post.location_hi!;
                              }
                              if (langCode == 'kn') {
                                return widget.post.location_kn!;
                              }
                              return widget.post.location_en!;
                            })(),
                            style: TextStyle(
                              color:
                                  theme.textTheme.bodySmall?.color?.withOpacity(
                                    0.7,
                                  ) ??
                                  Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Post Image
            if (widget.post.imageUrl != null)
              ClipRRect(
                child: Image.network(
                  widget.post.imageUrl!,
                  width: double.infinity,
                  height: 400,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => Container(
                        height: 400,
                        color: theme.dividerColor,
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                ),
              ),
            // Action Buttons
      Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color:
                              isLiked
                                  ? Colors.red
                                  : Theme.of(context).iconTheme.color,
                        ),
                        onPressed: _toggleLike,
                      ),
                      Text(
                        '${widget.post.likes.length}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(
                          Icons.comment_outlined,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        onPressed: () => _showComments(context),
                      ),
                      Text(
                        '${widget.post.commentsCount}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      if (widget.post.audioUrl != null) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(
                            _isPlaying ? Icons.pause : Icons.volume_up_outlined,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          onPressed: _playAudio,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Multilingual Content
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
              child: Text(
                postContent,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            // Caption
            if ((() {
              String langCode = Localizations.localeOf(context).languageCode;
              String? caption;
              if (langCode == 'hi') {
                caption = widget.post.caption_hi;
              } else if (langCode == 'kn')
                caption = widget.post.caption_kn;
              else
                caption = widget.post.caption_en;
              return caption?.isNotEmpty == true;
            })())
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                child: Text(
                  (() {
                    String langCode =
                        Localizations.localeOf(context).languageCode;
                    if (langCode == 'hi') return widget.post.caption_hi!;
                    if (langCode == 'kn') return widget.post.caption_kn!;
                    return widget.post.caption_en!;
                  })(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class CommentsSheet extends StatefulWidget {
  final String postId;

  const CommentsSheet({super.key, required this.postId});

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  final PostService _postService = PostService();
  final TextEditingController _commentController = TextEditingController();
  final String _currentUserId = FirebaseAuth.instance.currentUser!.uid;

  void _addComment() {
    if (_commentController.text.trim().isNotEmpty) {
      _postService.addComment(
        widget.postId,
        _currentUserId,
        _commentController.text.trim(),
      );
      _commentController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Comments List
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _postService.getCommentsStream(widget.postId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No comments yet.'));
                    }

                    final comments = snapshot.data!.docs;

                    return ListView.builder(
                      controller: controller,
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment =
                            comments[index].data() as Map<String, dynamic>;
                        return ListTile(
                          leading: const CircleAvatar(),
                          title: Text(
                            comment['userId'],
                          ), // Replace with username later
                          subtitle: Text(comment['text']),
                        );
                      },
                    );
                  },
                ),
              ),
              // Comment Input
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: 'Add a comment...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _addComment,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
