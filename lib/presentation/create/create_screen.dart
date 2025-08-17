import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  List<String> _hashtags = [];
  dynamic _image; // Can be File or XFile
  bool _isUploading = false;
  bool _isGenerating = false;

  void _onGenerationComplete(
    String content,
    String title,
    String location,
    List<String> hashtags,
  ) {
    if (mounted) {
      setState(() {
        _content = content;
        _title = title;
        _location = location;
        _hashtags = hashtags;
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
        hashtags: _hashtags,
        imageFile: !kIsWeb && _image != null ? _image as File : null,
        webImageFile: kIsWeb && _image != null ? _image as XFile : null,
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Post'),
        backgroundColor: const Color(0xFFF0EBE3),
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      backgroundColor: const Color(0xFFF0EBE3),
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
                    onGenerationComplete: (content, title, location, hashtags) {
                      setState(() {
                        _isGenerating = true;
                      });
                      _onGenerationComplete(content, title, location, hashtags);
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
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(_content),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(_location),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6.0,
                          runSpacing: 6.0,
                          children:
                              _hashtags
                                  .map((tag) => Chip(label: Text(tag)))
                                  .toList(),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[400]!),
                    ),
                    child:
                        _image == null
                            ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 8),
                                  Text('Tap to add an image'),
                                ],
                              ),
                            )
                            : ClipRRect(
                              borderRadius: BorderRadius.circular(11),
                              child:
                                  (kIsWeb
                                      ? Image.network(
                                        _image.path,
                                        fit: BoxFit.cover,
                                      )
                                      : Image.file(
                                        _image as File,
                                        fit: BoxFit.cover,
                                      )),
                            ),
                  ),
                ),
                const SizedBox(height: 32),
                _isUploading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                      onPressed: _createPost,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 0, 41, 36),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 15,
                        ),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                      child: const Text('Create Post'),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
