import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart';
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
    String caption,
    Uint8List? audioBytes,
  )
  onGenerationComplete;
  final String aiRole;

  const VoiceRecorderWidget({
    super.key,
    required this.onGenerationComplete,
    this.aiRole = 'Artist',
  });

  @override
  State<VoiceRecorderWidget> createState() => _VoiceRecorderWidgetState();
}

class _VoiceRecorderWidgetState extends State<VoiceRecorderWidget> {
  bool _isRecording = false;
  bool _isGenerating = false;
  String _transcribedText = "";
  Uint8List? _audioBytes;

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
              "You are an AI assistant that creates user bios from voice descriptions. The user is registering as an ${widget.aiRole}. Analyze the transcription and create a beautiful bio for an ${widget.aiRole}. Return a JSON object with: {\"title\": \"<1-2 words catchy title like 'Mosaic Artist', 'Art Admirer', etc.>\", \"location\": \"<inferred or mentioned location, or 'Unknown'>\", \"hashtags\": [\"#art\", \"#creative\", \"#inspiration\"], \"content\": \"<A poetic 3-4 sentence bio that captures emotion and story. Make it inspiring and artistic, like describing a creative person or admirer.>\", \"caption\": \"<A short inspirational quote or caption about art/creativity>\"}. Focus on making content that sounds like describing a beautiful person or creative admirer.",
        },
        {"role": "user", "content": transcription},
      ],
      "temperature": 0.8,
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
            extractedData['caption'] ?? 'Every piece tells a story',
            _audioBytes,
          );
        } else {
          print('API Error: ${response.body}');
          // Fallback with just the transcription
          widget.onGenerationComplete(
            transcription,
            'Untitled',
            'Unknown',
            [],
            'Every piece tells a story',
            _audioBytes,
          );
        }
      }
    } catch (e) {
      print('Network Error: $e');
      if (mounted) {
        widget.onGenerationComplete(
          transcription,
          'Untitled',
          'Unknown',
          [],
          'Every piece tells a story',
          _audioBytes,
        );
      }
    }
  }

  Future<void> _handleMicTap() async {
    if (await _audioRecorder.hasPermission()) {
      if (_isRecording) {
        String? path;
        Uint8List? audioBytes;
        if (kIsWeb) {
          // On web, stop and get URL, then fetch bytes
          path = await _audioRecorder.stop();
          await _speechToText.stop();
          if (path != null) {
            try {
              final response = await http.get(Uri.parse(path));
              audioBytes = response.bodyBytes;
            } catch (e) {
              print('Error fetching audio bytes from web: $e');
            }
          }
        } else {
          path = await _audioRecorder.stop();
          await _speechToText.stop();
          if (path != null) {
            try {
              audioBytes = await File(path).readAsBytes();
            } catch (e) {
              print('Error reading audio bytes: $e');
            }
          }
        }
        if (mounted) {
          setState(() {
            _isRecording = false;
            _isGenerating = true;
            _audioBytes = audioBytes;
          });
        }

        await _generatePostWithGroq(_transcribedText);

        if (mounted) {
          setState(() {
            _isGenerating = false;
          });
        }
      } else {
        if (kIsWeb) {
          await _audioRecorder.start(
            const RecordConfig(),
            path: 'audio_recording_web.m4a', // dummy path for web
          );
        } else {
          await _audioRecorder.start(
            const RecordConfig(),
            path: 'audio_recording.m4a',
          );
        }
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
