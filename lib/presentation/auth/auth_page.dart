import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../create/widgets/voice_recorder_widget.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';

import 'package:google_fonts/google_fonts.dart';
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

  bool _isRegisterMode = false;
  bool _isLoading = false;

  bool _showOtpField = false;

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
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final backgroundColor = theme.scaffoldBackgroundColor;
    return Scaffold(
      backgroundColor: backgroundColor,

      body: SafeArea(
        child: Center(
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
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Icon(
            Icons.mic_rounded,
            size: 45,
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'VocalCanvas',
          style: GoogleFonts.inter(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color:
                Theme.of(context).textTheme.titleLarge?.color ??
                Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your Voice, Your Story',
          style: GoogleFonts.inter(
            fontSize: 16,
            color:
                Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withOpacity(0.8) ??
                Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
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
            'Select your role:',
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
                label: const Text('Artist'),
                selected: _role == 'Artist',
                onSelected: (selected) {
                  setState(() {
                    _role = 'Artist';
                  });
                },
              ),
              const SizedBox(width: 16),
              ChoiceChip(
                label: const Text('Admirer'),
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
            'Record a short voice intro for your bio',
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
                    'Generated Bio:',
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                  ),
                  Text(_generatedBio!, style: GoogleFonts.inter()),
                  if (_generatedLocation != null)
                    Text(
                      'Location: $_generatedLocation',
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
              child: const Text('Finish Registration'),
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
            _isRegisterMode ? 'Create your Account' : 'Welcome Back',
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
              label: 'Full Name',
              icon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: 16),
          ],
          _buildTextField(
            controller: _emailController,
            label: 'Email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _passwordController,
            label: 'Password',
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
              child: const Text('Next: Record Voice Bio'),
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
                  _isRegisterMode ? 'Create Account' : 'Sign In',
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
              ? 'Already have an account?'
              : "Don't have an account?",
          style: GoogleFonts.inter(color: primaryColor.withOpacity(0.8)),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              _isRegisterMode = !_isRegisterMode;
            });
          },
          child: Text(
            _isRegisterMode ? 'Sign In' : 'Register',
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
          'By continuing, you agree to our Terms of Service and Privacy Policy.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: primaryColor.withOpacity(0.6),
          ),
        ),
        if (kIsWeb && _showOtpField) ...[
          const SizedBox(height: 16),
          const Text(
            'This site is protected by reCAPTCHA and the Google Privacy Policy and Terms of Service apply.',
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
      _showErrorDialog('Please fill in all fields.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
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
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _generatedBio == null ||
        _profileAudioBytes == null) {
      _showErrorDialog('Please fill in all fields and record your bio.');
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
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'bio': _generatedBio,
          'location': _generatedLocation,
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

  // Helper Methods
  void _navigateToHome() {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  String _getFirebaseAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
