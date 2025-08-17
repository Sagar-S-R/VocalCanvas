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
  String? _generatedPost;
  File? _imageFile;
  XFile? _webImageFile;
  Uint8List? _webImageBytes;
  final PostService _postService = PostService();

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        if (kIsWeb) {
          _webImageFile = pickedFile;
          // Load the image bytes for web display
          pickedFile.readAsBytes().then((bytes) {
            setState(() {
              _webImageBytes = bytes;
            });
          });
        } else {
          _imageFile = File(pickedFile.path);
        }
      });
    }
  }

  void _createPost() {
    if (_generatedPost != null) {
      // In a real app, you would get the actual user ID.
      _postService.createPost(
        content: _generatedPost!,
        userId: 'current_user',
        imageFile: _imageFile,
        webImageFile: _webImageFile,
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: const Color(0xFFF0EBE3),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Create a New Post',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Lora',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Conditionally show the recorder or the result.
                    if (_generatedPost == null) ...[
                      const Text(
                        'Tap the button and tell us about your art. Your voice is the spark.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black54, fontSize: 20),
                      ),
                      const SizedBox(height: 60),
                      VoiceRecorderWidget(
                        onGenerationComplete: (String text) {
                          setState(() {
                            _generatedPost = text;
                          });
                        },
                      ),
                    ] else ...[
                      // Show generated text and image upload
                      GeneratedPostCard(
                        generatedText: _generatedPost!,
                        imageFile: _imageFile,
                        webImageBytes: _webImageBytes,
                        onPickImage: _pickImage,
                        onCreatePost: _createPost,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GeneratedPostCard extends StatelessWidget {
  final String generatedText;
  final File? imageFile;
  final Uint8List? webImageBytes;
  final VoidCallback onPickImage;
  final VoidCallback onCreatePost;

  const GeneratedPostCard({
    super.key,
    required this.generatedText,
    this.imageFile,
    this.webImageBytes,
    required this.onPickImage,
    required this.onCreatePost,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            generatedText,
            style: const TextStyle(fontSize: 18, fontFamily: 'Lora'),
          ),
          const SizedBox(height: 24),
          if (imageFile != null || webImageBytes != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child:
                  kIsWeb && webImageBytes != null
                      ? Image.memory(
                        webImageBytes!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                      : imageFile != null
                      ? Image.file(
                        imageFile!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                      : Container(),
            ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onPickImage,
            icon: const Icon(Icons.image),
            label: const Text('Upload Image'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color.fromARGB(255, 0, 41, 36),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              textStyle: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onCreatePost,
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.green.shade800,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: const Text('Create Post'),
          ),
        ],
      ),
    );
  }
}
