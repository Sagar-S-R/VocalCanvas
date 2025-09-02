import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:http/http.dart' as http;
import '../../../config/api_config.dart';
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

    _apiKey = ApiConfig.getGeminiApiKey();
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

  Future<String> _translateText(String text, String targetLanguage) async {
    if (_apiKey.isEmpty) {
      return 'Translation requires API key';
    }

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_apiKey',
    );
    final headers = {'Content-Type': 'application/json'};

    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": "Translate the following text to $targetLanguage: $text"},
          ],
        },
      ],
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return responseBody['candidates'][0]['content']['parts'][0]['text'];
      } else {
        return 'Translation failed';
      }
    } catch (e) {
      return 'Translation failed';
    }
  }

  Future<void> _generatePostWithGemini(String transcription) async {
    if (_apiKey.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Gemini API key is missing. Please add it to your .env file.',
            ),
          ),
        );
      }
      return;
    }

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$_apiKey',
    );
    final headers = {'Content-Type': 'application/json'};

    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {
              "text":
                  "You are an AI assistant that creates user bios from voice descriptions. The user is registering as an ${widget.aiRole}. Analyze the transcription and create a beautiful bio for an ${widget.aiRole}. Return a JSON object with: {\"title\": \"<1-2 words catchy title like 'Mosaic Artist', 'Art Admirer', etc.>\", \"location\": \"<inferred or mentioned location, or 'Unknown'>\", \"hashtags\": [\"#art\", \"#creative\", \"#inspiration\"], \"content\": \"<A poetic 3-4 sentence bio that captures emotion and story. Make it inspiring and artistic, like describing a creative person or admirer.>\", \"caption\": \"<A short inspirational quote or caption about art/creativity>\"}. Focus on making content that sounds like describing a beautiful person or creative admirer. User's transcription: $transcription",
            },
          ],
        },
      ],
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (mounted) {
        if (response.statusCode == 200) {
          final responseBody = jsonDecode(response.body);
          String contentJson =
              responseBody['candidates'][0]['content']['parts'][0]['text'];

          // Clean the JSON string from markdown and other text
          final jsonStart = contentJson.indexOf('{');
          final jsonEnd = contentJson.lastIndexOf('}');

          if (jsonStart != -1 && jsonEnd != -1) {
            contentJson = contentJson.substring(jsonStart, jsonEnd + 1);
          }

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

        await _generatePostWithGemini(_transcribedText);

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
