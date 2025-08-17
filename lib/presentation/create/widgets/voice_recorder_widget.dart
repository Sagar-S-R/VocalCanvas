import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class VoiceRecorderWidget extends StatefulWidget {
  final Function(String) onGenerationComplete;

  const VoiceRecorderWidget({super.key, required this.onGenerationComplete});

  @override
  State<VoiceRecorderWidget> createState() => _VoiceRecorderWidgetState();
}

class _VoiceRecorderWidgetState extends State<VoiceRecorderWidget> {
  bool _isRecording = false;
  bool _isGenerating = false;
  String _transcribedText = "";

  final AudioRecorder _audioRecorder = AudioRecorder();
  final SpeechToText _speechToText = SpeechToText();

  late final String _apiKey;

  @override
  void initState() {
    super.initState();
    _initSpeechToText();

    _apiKey = dotenv.env['GROQ_API_KEY'] ?? '';
  }

  void _initSpeechToText() async {
    await _speechToText.initialize();
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _speechToText.cancel();
    super.dispose();
  }

  Future<void> _generatePostWithGroq(String transcription) async {
    if (_apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Groq API key is missing. Please add it to your .env file.',
          ),
        ),
      );
      return;
    }

    final url = Uri.parse('https://api.groq.com/openai/v1/chat/completions');
    final headers = {
      'Authorization': 'Bearer $_apiKey',
      'Content-Type': 'application/json',
    };

    final prompt =
        'Take this transcription and generate a 5-line paragraph about this artist for their Instagram, with 5 relevant hashtags. '
        'Transcription: "$transcription"';

    final body = jsonEncode({
      "messages": [
        {"role": "user", "content": prompt},
      ],
      "model": "llama3-8b-8192",
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final generatedPost = responseBody['choices'][0]['message']['content'];
        widget.onGenerationComplete(generatedPost);
      } else {
        print('API Error: ${response.body}');
        widget.onGenerationComplete("Error: Could not generate post.");
      }
    } catch (e) {
      print('Network Error: $e');
      widget.onGenerationComplete("Error: Network issue.");
    }
  }

  Future<void> _handleMicTap() async {
    if (await _audioRecorder.hasPermission()) {
      if (_isRecording) {
        await _audioRecorder.stop();
        await _speechToText.stop();

        if (mounted) {
          setState(() {
            _isRecording = false;
            _isGenerating = true;
          });
        }

        await _generatePostWithGroq(_transcribedText);

        if (mounted) {
          setState(() {
            _isGenerating = false;
          });
        }
      } else {
        await _audioRecorder.start(
          const RecordConfig(),
          path: 'audio_recording.m4a',
        );
        _speechToText.listen(
          onResult: (result) {
            if (mounted) {
              setState(() {
                _transcribedText = result.recognizedWords;
              });
            }
          },
        );
        if (mounted) {
          setState(() {
            _isRecording = true;
          });
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission is required.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const themeColor = Color.fromARGB(255, 0, 41, 36);

    return Column(
      children: [
        GestureDetector(
          onTap: _handleMicTap,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: themeColor,
              boxShadow: [
                BoxShadow(
                  color: themeColor.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Center(
              child:
                  _isGenerating
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Icon(
                        _isRecording ? Icons.stop : Icons.mic,
                        color: Colors.white,
                        size: 80,
                      ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (_isRecording)
          Text(
            _transcribedText,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54, fontSize: 16),
          ),
      ],
    );
  }
}
