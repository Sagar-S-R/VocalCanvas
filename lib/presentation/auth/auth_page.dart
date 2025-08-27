import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../create/widgets/voice_recorder_widget.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
// ...existing code...

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  String _role = 'Artist'; // Artist or Admirer
  // Registration step control
  int _registerStep = 0; // 0: form, 1: voice recording
  String? _generatedBio;
  String? _generatedLocation;
  Uint8List? _profileAudioBytes;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isRegisterMode = false;
  bool _isLoading = false;

  final bool _showOtpField = false;

  // Colors
  // Theme-aware colors will be used inside build via Theme.of(context)

  // Provide convenient getters that use the current BuildContext
  Color get primaryColor => Theme.of(context).primaryColor;
  Color get backgroundColor => Theme.of(context).scaffoldBackgroundColor;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final screenWidth = MediaQuery.of(context).size.width;
    final showTrees = screenWidth >= 700;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Decorative images on both sides for wide screens
            if (showTrees) ...[
              // Existing tree.png (centered vertically on the left)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Opacity(
                    opacity: 0.5,
                    child: Image.asset(
                      'assets/tree.png',
                      height: 700,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 230,
                bottom: 30,
                child: Opacity(
                  opacity: 0.8,
                  child: Image.asset(
                    'assets/plant1.png',
                    height: 225,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                right: 235,
                top: 30,
                child: Opacity(
                  opacity: 0.8,
                  child: Image.asset(
                    'assets/plant2.png',
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              // Existing tree2.png (centered vertically on the right)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Opacity(
                    opacity: 0.5,
                    child: Image.asset(
                      'assets/tree2.png',
                      height: 700,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
            // Language Toggle at top-right without removing existing UI
            Positioned(top: 8, right: 8, child: _buildLanguageToggle(context)),
            Center(
              child: SingleChildScrollView(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLogoSection(),
                        const SizedBox(height: 32),
                        _buildAuthForm(),
                        const SizedBox(height: 24),
                        _buildFooter(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageToggle(BuildContext context) {
    final current = context.locale.languageCode;
    String label;
    switch (current) {
      case 'hi':
        label = 'हिंदी';
        break;
      case 'kn':
        label = 'ಕನ್ನಡ';
        break;
      default:
        label = 'EN';
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: PopupMenuButton<Locale>(
        tooltip: tr('choose_language'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onSelected: (locale) async {
          await context.setLocale(locale);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('languageCode', locale.languageCode);
          if (mounted) setState(() {});
        },
        itemBuilder:
            (context) => [
              PopupMenuItem(
                value: const Locale('en'),
                child: const Text('English'),
              ),
              PopupMenuItem(
                value: const Locale('hi'),
                child: const Text('हिंदी'),
              ),
              PopupMenuItem(
                value: const Locale('kn'),
                child: const Text('ಕನ್ನಡ'),
              ),
            ],
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.language, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // New VocalCanvas logo
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: theme.primaryColor.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset(
              isDark ? 'logo_dark.png' : 'logo_light.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // Fallback to old design if images not found
                return Container(
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    Icons.mic_rounded,
                    size: 60,
                    color: theme.scaffoldBackgroundColor,
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'VocalCanvas',
          style: GoogleFonts.inter(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          tr('tagline'),
          style: GoogleFonts.inter(
            fontSize: 16,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildAuthForm() {
    if (_isRegisterMode && _registerStep == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            tr('select_role'),
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color:
                  Theme.of(context).textTheme.titleMedium?.color ??
                  Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChoiceChip(
                label: Text(tr('artist')),
                selected: _role == 'Artist',
                onSelected: (selected) {
                  setState(() {
                    _role = 'Artist';
                  });
                },
              ),
              const SizedBox(width: 16),
              ChoiceChip(
                label: Text(tr('admirer')),
                selected: _role == 'Admirer',
                onSelected: (selected) {
                  setState(() {
                    _role = 'Admirer';
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            tr('record_bio_prompt'),
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color:
                  Theme.of(context).textTheme.titleLarge?.color ??
                  Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
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
                _generatedBio = content;
                _generatedLocation = location;
                _profileAudioBytes = audioBytes;
                _isLoading = false;
              });
            },
            aiRole: _role,
          ),
          if (_generatedBio != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr('generated_bio'),
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                  ),
                  Text(_generatedBio!, style: GoogleFonts.inter()),
                  if (_generatedLocation != null)
                    Text(
                      '${tr('location')}: $_generatedLocation',
                      style: GoogleFonts.inter(),
                    ),
                ],
              ),
            ),
          if (_generatedBio != null)
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _registerStep = 2;
                  _isLoading = true;
                });
                _registerWithEmail();
              },
              child: Text(tr('finish_registration')),
            ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      );
    } else if (_isRegisterMode && _registerStep == 2) {
      return Center(child: CircularProgressIndicator());
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _isRegisterMode ? tr('create_account_title') : tr('welcome_back'),
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color:
                  Theme.of(context).textTheme.titleLarge?.color ??
                  Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 24),
          if (_isRegisterMode) ...[
            _buildTextField(
              controller: _nameController,
              label: tr('full_name'),
              icon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _phoneController,
              label: tr('phone'),
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
          ],
          _buildTextField(
            controller: _emailController,
            label: _isRegisterMode ? tr('email') : tr('email_or_phone'),
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _passwordController,
            label: tr('password'),
            icon: Icons.lock_outline_rounded,
            obscureText: true,
          ),
          const SizedBox(height: 24),
          if (_isRegisterMode)
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _registerStep = 1;
                });
              },
              child: Text(tr('next_record_bio')),
            ),
          if (!_isRegisterMode) _buildAuthButton(),
          const SizedBox(height: 16),
          _buildToggleModeButton(),
        ],
      );
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(
        color:
            Theme.of(context).textTheme.bodyMedium?.color ??
            Theme.of(context).colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(
          color:
              Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7) ??
              Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        ),
        prefixIcon: Icon(icon, color: Theme.of(context).iconTheme.color),
        filled: true,
        fillColor: Theme.of(context).cardColor.withOpacity(0.04),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildAuthButton() {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
          shadowColor: primaryColor.withOpacity(0.4),
        ),
        onPressed:
            _isLoading
                ? null
                : (_isRegisterMode ? _registerWithEmail : _signInWithEmail),
        child:
            _isLoading
                ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
                : Text(
                  _isRegisterMode ? tr('create_account_button') : tr('sign_in'),
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
      ),
    );
  }

  Widget _buildToggleModeButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isRegisterMode
              ? tr('already_have_account')
              : tr('dont_have_account'),
          style: GoogleFonts.inter(color: primaryColor.withOpacity(0.8)),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              _isRegisterMode = !_isRegisterMode;
            });
          },
          child: Text(
            _isRegisterMode ? tr('sign_in') : tr('register'),
            style: GoogleFonts.inter(
              color: primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          tr('terms_and_privacy_disclaimer'),
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: primaryColor.withOpacity(0.6),
          ),
        ),
        if (kIsWeb && _showOtpField) ...[
          const SizedBox(height: 16),
          Text(
            tr('recaptcha_notice'),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ],
    );
  }

  // Authentication Methods
  Future<void> _signInWithEmail() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorDialog(tr('fill_all_fields'));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final identifier = _emailController.text.trim();
      String emailToUse = identifier;
      // If identifier is not an email, try treating it as phone: lookup email by phone
      final isEmail = RegExp(
        r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
      ).hasMatch(identifier);
      if (!isEmail) {
        final query =
            await FirebaseFirestore.instance
                .collection('users')
                .where('phone', isEqualTo: identifier)
                .limit(1)
                .get();
        if (query.docs.isEmpty) {
          throw FirebaseAuthException(
            code: 'user-not-found',
            message: 'User not found',
          );
        }
        final data = query.docs.first.data();
        final foundEmail = data['email'];
        if (foundEmail is String && foundEmail.isNotEmpty) {
          emailToUse = foundEmail;
        } else {
          throw FirebaseAuthException(
            code: 'user-not-found',
            message: 'User not found',
          );
        }
      }

      await _auth.signInWithEmailAndPassword(
        email: emailToUse,
        password: _passwordController.text,
      );
      _navigateToHome();
    } on FirebaseAuthException catch (e) {
      _showErrorDialog(_getFirebaseAuthErrorMessage(e));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _registerWithEmail() async {
    if (_nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _generatedBio == null ||
        _profileAudioBytes == null) {
      _showErrorDialog(tr('fill_fields_and_record_bio'));
      return;
    }

    setState(() {
      _isLoading = true;
      _registerStep = 2;
    });

    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      // Update user profile with name
      await userCredential.user?.updateDisplayName(_nameController.text.trim());

      // Store user details in Firestore
      final userId = userCredential.user?.uid;
      if (userId != null) {
        final audioBase64 = base64Encode(_profileAudioBytes!);
        final audioUrl = 'data:audio/m4a;base64,$audioBase64';

        // Prepare multilingual fields
        final nameEn = _nameController.text.trim();
        final bioEn = _generatedBio ?? '';
        final locEn = _generatedLocation ?? '';

        String? nameHi;
        String? nameKn;
        String? bioHi;
        String? bioKn;
        String? locHi;
        String? locKn;

        // Translate using Gemini if API key is available
        final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
        if (apiKey.isNotEmpty) {
          try {
            final results = await Future.wait<String?>([
              _translateText(nameEn, 'Hindi'),
              _translateText(nameEn, 'Kannada'),
              _translateText(bioEn, 'Hindi'),
              _translateText(bioEn, 'Kannada'),
              _translateText(locEn, 'Hindi'),
              _translateText(locEn, 'Kannada'),
            ]);
            nameHi = _nullIfEmpty(results[0]);
            nameKn = _nullIfEmpty(results[1]);
            bioHi = _nullIfEmpty(results[2]);
            bioKn = _nullIfEmpty(results[3]);
            locHi = _nullIfEmpty(results[4]);
            locKn = _nullIfEmpty(results[5]);
          } catch (_) {
            // Fallback: keep only English if translation fails
          }
        }

        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'name_en': nameEn,
          if (nameHi != null) 'name_hi': nameHi,
          if (nameKn != null) 'name_kn': nameKn,
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'bio_en': bioEn,
          if (bioHi != null) 'bio_hi': bioHi,
          if (bioKn != null) 'bio_kn': bioKn,
          'location_en': locEn,
          if (locHi != null) 'location_hi': locHi,
          if (locKn != null) 'location_kn': locKn,
          'audioUrl': audioUrl,
        });
      }

      _navigateToHome();
    } on FirebaseAuthException catch (e) {
      _showErrorDialog(_getFirebaseAuthErrorMessage(e));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _registerStep = 0;
        });
      }
    }
  }

  String? _nullIfEmpty(String? s) =>
      (s == null || s.trim().isEmpty) ? null : s.trim();

  Future<String?> _translateText(String text, String targetLanguage) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (apiKey.isEmpty) return null;
    if (text.trim().isEmpty) return '';

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey',
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
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final translated =
            decoded['candidates']?[0]?['content']?['parts']?[0]?['text'];
        if (translated is String) return translated.trim();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // Helper Methods
  void _navigateToHome() {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(tr('error_title')),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(tr('ok')),
              ),
            ],
          ),
    );
  }

  String _getFirebaseAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return tr('err_user_not_found');
      case 'wrong-password':
        return tr('err_wrong_password');
      case 'email-already-in-use':
        return tr('err_email_in_use');
      case 'weak-password':
        return tr('err_weak_password');
      case 'invalid-email':
        return tr('err_invalid_email');
      case 'too-many-requests':
        return tr('err_too_many_requests');
      case 'operation-not-allowed':
        return tr('err_operation_not_allowed');
      default:
        return tr('err_generic');
    }
  }
}
