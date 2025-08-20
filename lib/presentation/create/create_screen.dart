import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'widgets/voice_recorder_widget.dart'; // Import the voice recorder widget
import '../../core/services/post_service.dart';

class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  final PostService _postService = PostService();
  String _content = '';
  String _title = '';
  String _location = '';
  String _caption = '';
  List<String> _hashtags = [];
  dynamic _image; // Can be File or XFile
  Uint8List? _audioBytes;
  bool _isUploading = false;
  bool _isGenerating = false;

  void _onGenerationComplete(
    String content,
    String title,
    String location,
    List<String> hashtags,
    String caption,
    Uint8List? audioBytes,
  ) {
    if (mounted) {
      setState(() {
        _content = content;
        _title = title;
        _location = location;
        _hashtags = hashtags;
        _caption = caption;
        _audioBytes = audioBytes;
        _isGenerating = false; // Generation is complete
      });
    }
  }

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (image != null) {
      if (kIsWeb) {
        setState(() {
          _image = image;
        });
      } else {
        setState(() {
          _image = File(image.path);
        });
      }
    }
  }

  Future<void> _createPost() async {
    if (_content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please generate content first.')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      await _postService.createPost(
        content: _content,
        title: _title,
        location: _location,
        caption: _caption,
        hashtags: _hashtags,
        imageFile: !kIsWeb && _image != null ? _image as File : null,
        webImageFile: kIsWeb && _image != null ? _image as XFile : null,
        audioBytes: _audioBytes,
        userId: 'current_user', // Replace with actual user ID
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post created successfully!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to create post: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('create_new_post'.tr()),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        foregroundColor: theme.appBarTheme.foregroundColor,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (_content.isEmpty)
                  VoiceRecorderWidget(
                    onGenerationComplete: (
                      content,
                      title,
                      location,
                      hashtags,
                      caption,
                      audioBytes,
                    ) {
                      setState(() {
                        _isGenerating = true;
                      });
                      _onGenerationComplete(
                        content,
                        title,
                        location,
                        hashtags,
                        caption,
                        audioBytes,
                      );
                    },
                  )
                else
                  Container(), // Placeholder

                if (_isGenerating)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text("Generating content..."),
                      ],
                    ),
                  ),

                if (_content.isNotEmpty && !_isGenerating)
                  Container(
                    height: 400,
                    margin: const EdgeInsets.symmetric(vertical: 16),
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
                          // Background - either image or gradient
                          Positioned.fill(
                            child:
                                _image != null
                                    ? (kIsWeb
                                        ? Image.network(
                                          _image.path,
                                          fit: BoxFit.cover,
                                        )
                                        : Image.file(
                                          _image as File,
                                          fit: BoxFit.cover,
                                        ))
                                    : Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            theme.colorScheme.primary
                                                .withOpacity(0.8),
                                            theme.colorScheme.primary
                                                .withOpacity(0.6),
                                            theme.colorScheme.primary
                                                .withOpacity(0.4),
                                          ],
                                        ),
                                      ),
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
                                    Colors.black.withOpacity(0.25),
                                    Colors.black.withOpacity(0.6),
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
                                  if (_location.isNotEmpty &&
                                      _location != 'Unknown')
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme.scaffoldBackgroundColor
                                            .withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: theme.scaffoldBackgroundColor
                                              .withOpacity(0.12),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        _location,
                                        style:
                                            theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                  color:
                                                      theme
                                                          .colorScheme
                                                          .onBackground,
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

                                  const Spacer(),

                                  // Caption/Description
                                  if (_caption.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      child: Text(
                                        _caption,
                                        style:
                                            theme.textTheme.bodyLarge?.copyWith(
                                              color:
                                                  theme
                                                      .colorScheme
                                                      .onBackground,
                                              fontSize: 16,
                                              height: 1.4,
                                              fontWeight: FontWeight.w400,
                                            ) ??
                                            const TextStyle(
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
                                    _title,
                                    style:
                                        theme.textTheme.headlineLarge?.copyWith(
                                          color: theme.colorScheme.onBackground,
                                          fontSize: 36,
                                          fontWeight: FontWeight.bold,
                                          height: 1.1,
                                        ) ??
                                        const TextStyle(
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
                                  if (_hashtags.isNotEmpty)
                                    Wrap(
                                      spacing: 8,
                                      children:
                                          _hashtags.take(3).map((tag) {
                                            return Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(
                                                  0.1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
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
                // Image picker - only show if content is generated and no image selected
                if (_content.isNotEmpty && _image == null)
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(
                            255,
                            0,
                            41,
                            36,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color.fromARGB(
                              255,
                              0,
                              41,
                              36,
                            ).withOpacity(0.3),
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate,
                                size: 40,
                                color: Color.fromARGB(255, 0, 41, 36),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Tap to add your artwork image',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 0, 41, 36),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'The image will enhance your art post',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                // Change image button if image is selected
                if (_content.isNotEmpty && _image != null)
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.edit),
                          label: const Text('Change Image'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color.fromARGB(
                              255,
                              0,
                              41,
                              36,
                            ),
                            side: const BorderSide(
                              color: Color.fromARGB(255, 0, 41, 36),
                              width: 1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _image = null;
                            });
                          },
                          icon: const Icon(Icons.delete),
                          label: const Text('Remove Image'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade50,
                            foregroundColor: Colors.red.shade700,
                            side: BorderSide(
                              color: Colors.red.shade300,
                              width: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 40),

                // Create Post Button
                if (_content.isNotEmpty)
                  SizedBox(
                    width: double.infinity,
                    child:
                        _isUploading
                            ? Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: const Center(
                                child: Column(
                                  children: [
                                    CircularProgressIndicator(
                                      color: Color.fromARGB(255, 0, 41, 36),
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      'Creating your masterpiece...',
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 0, 41, 36),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            : ElevatedButton(
                              onPressed: _createPost,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  0,
                                  41,
                                  36,
                                ),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              child: const Text(
                                'Share Your Art Story',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
