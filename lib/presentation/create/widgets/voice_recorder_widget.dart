import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class VoiceRecorderWidget extends StatefulWidget {
  final Function(
    String content,
    String title,
    String location,
    List<String> hashtags,
  )
  onGenerationComplete;

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
    if (_speechToText.isListening) {
      _speechToText.cancel();
    }
    super.dispose();
  }

  Future<void> _generatePostWithGroq(String transcription) async {
    if (_apiKey.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Groq API key is missing. Please add it to your .env file.',
            ),
          ),
        );
      }
      return;
    }

    final url = Uri.parse('https://api.groq.com/openai/v1/chat/completions');
    final headers = {
      'Authorization': 'Bearer $_apiKey',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      "model": "llama3-8b-8192",
      "messages": [
        {
          "role": "system",
          "content":
              "You are a helpful assistant that analyzes a given text to extract specific information. The user will provide a text transcription. Your task is to return a JSON object with the following structure: {\"title\": \"<A suitable title for the post>\", \"location\": \"<The location mentioned, or 'Unknown' if not specified>\", \"hashtags\": [\"#hashtag1\", \"#hashtag2\"], \"content\": \"<The original transcribed text>\"}. Ensure the hashtags are relevant to the content and the content is the same as the transcription.",
        },
        {"role": "user", "content": transcription},
      ],
      "temperature": 0.7,
      "response_format": {"type": "json_object"},
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (mounted) {
        if (response.statusCode == 200) {
          final responseBody = jsonDecode(response.body);
          final contentJson = responseBody['choices'][0]['message']['content'];
          final extractedData = jsonDecode(contentJson);

          widget.onGenerationComplete(
            extractedData['content'] ?? transcription,
            extractedData['title'] ?? 'Untitled',
            extractedData['location'] ?? 'Unknown',
            List<String>.from(extractedData['hashtags'] ?? []),
          );
        } else {
          print('API Error: ${response.body}');
          // Fallback with just the transcription
          widget.onGenerationComplete(transcription, 'Untitled', 'Unknown', []);
        }
      }
    } catch (e) {
      print('Network Error: $e');
      if (mounted) {
        widget.onGenerationComplete(transcription, 'Untitled', 'Unknown', []);
      }
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
