import 'package:flutter/material.dart';
import 'widgets/voice_recorder_widget.dart'; // Import the voice recorder widget

class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  // New state variable to hold the AI-generated post.
  String? _generatedPost;

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
                        // This function receives the generated text from the widget.
                        onGenerationComplete: (generatedText) {
                          setState(() {
                            _generatedPost = generatedText;
                          });
                        },
                      ),
                    ] else ...[
                      // Display the generated post in a new card.
                      const SizedBox(height: 40),
                      GeneratedPostCard(
                        postText: _generatedPost!,
                        onRetry: () {
                          setState(() {
                            _generatedPost = null;
                          });
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          // Floating back button
          Positioned(
            top: 40,
            left: 40,
            child: FloatingActionButton(
              onPressed: () => Navigator.of(context).pop(),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 4,
              child: const Icon(Icons.arrow_back),
            ),
          ),
        ],
      ),
    );
  }
}

// A new widget to display the AI-generated post.
class GeneratedPostCard extends StatelessWidget {
  final String postText;
  final VoidCallback onRetry;

  const GeneratedPostCard({
    super.key,
    required this.postText,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Generated Post',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'Lora',
              color: Colors.black,
            ),
          ),
          const Divider(height: 30),
          Text(
            postText,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 0, 41, 36),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement copy to clipboard or post to social media.
                },
                icon: const Icon(Icons.copy),
                label: const Text('Copy & Use'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 0, 41, 36),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
