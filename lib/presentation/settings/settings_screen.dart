// Modern SettingsScreen
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../utils/theme_provider.dart';

import '../../data/models/user_model.dart';

// UserModel (assuming this is in a separate file)
// User Service for Firestore operations
class UserService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<UserModel?> getCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc.data()!, doc.id);
      }
    } catch (e) {
      print('Error fetching user: $e');
    }
    return null;
  }

  static Future<bool> updateUser(UserModel userModel) async {
    try {
      await _firestore
          .collection('users')
          .doc(userModel.id)
          .update(userModel.toFirestore());
      return true;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }

  static Future<bool> updateEmail(String newEmail) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      await user.updateEmail(newEmail);
      await _firestore.collection('users').doc(user.uid).update({
        'email': newEmail,
      });
      return true;
    } catch (e) {
      print('Error updating email: $e');
      return false;
    }
  }

  static Future<bool> updatePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);
      return true;
    } catch (e) {
      print('Error updating password: $e');
      return false;
    }
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  UserModel? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await UserService.getCurrentUser();
    setState(() {
      _currentUser = user;
      _isLoading = false;
    });
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDark;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    _buildHeader(theme),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        children: [
                          const SizedBox(height: 20),
                          _buildProfileSection(theme),
                          const SizedBox(height: 24),
                          _buildPreferencesSection(
                            theme,
                            isDarkMode,
                            themeProvider,
                          ),
                          const SizedBox(height: 24),
                          _buildAccountSection(theme),
                          const SizedBox(height: 24),
                          _buildLegalSection(theme),
                          const SizedBox(height: 24),
                          _buildAppInfoSection(theme),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      // Removed gradient background to keep header plain
      child: Row(
        children: [
          Text(
            'settings'.tr(),
            style:
                theme.textTheme.headlineLarge?.copyWith(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Serif',
                ) ??
                const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Serif',
                ),
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () {},
              icon: Icon(Icons.info_outline, color: theme.colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernCard({
    required Widget child,
    required ThemeData theme,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme, {IconData? icon}) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, color: theme.colorScheme.primary, size: 24),
          const SizedBox(width: 12),
        ],
        Text(
          title,
          style:
              theme.textTheme.titleLarge?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ) ??
              TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
        ),
      ],
    );
  }

  Widget _buildProfileSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Profile', theme, icon: Icons.person_outline),
        const SizedBox(height: 16),
        _buildModernCard(
          theme: theme,
          child: Column(
            children: [
              _buildModernListTile(
                icon: Icons.edit_outlined,
                title: 'edit_profile'.tr(),
                subtitle:
                    _currentUser?.name_en ?? 'Update your profile information',
                onTap: () => _showEditProfileDialog(),
                theme: theme,
              ),
              const Divider(height: 1),
              _buildModernListTile(
                icon: Icons.lock_outline,
                title: 'Change Password',
                subtitle: 'Update your account password',
                onTap: () => _showChangePasswordDialog(),
                theme: theme,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreferencesSection(
    ThemeData theme,
    bool isDarkMode,
    ThemeProvider themeProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Preferences', theme, icon: Icons.tune_outlined),
        const SizedBox(height: 16),
        _buildModernCard(
          theme: theme,
          child: Column(
            children: [
              _buildModernListTile(
                icon: Icons.language_outlined,
                title: "choose_language".tr(),
                subtitle:
                    context.locale.languageCode == 'en'
                        ? 'English'
                        : context.locale.languageCode == 'hi'
                        ? 'हिन्दी'
                        : 'ಕನ್ನಡ',
                onTap: () => _showLanguageDialog(context),
                theme: theme,
              ),
              const Divider(height: 1),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isDarkMode
                            ? Icons.dark_mode_outlined
                            : Icons.light_mode_outlined,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "dark_mode".tr(),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isDarkMode
                                ? 'Dark theme enabled'
                                : 'Light theme enabled',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.7,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: isDarkMode,
                      onChanged: (val) => themeProvider.setDarkMode(val),
                      activeColor: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'Account',
          theme,
          icon: Icons.account_circle_outlined,
        ),
        const SizedBox(height: 16),
        _buildModernCard(
          theme: theme,
          child: _buildModernListTile(
            icon: Icons.logout_outlined,
            title: 'Logout',
            subtitle: 'Sign out of your account',
            onTap: () => _handleLogout(context),
            theme: theme,
            isDestructive: true,
          ),
        ),
      ],
    );
  }

  Widget _buildLegalSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Legal', theme, icon: Icons.gavel_outlined),
        const SizedBox(height: 16),
        _buildModernCard(
          theme: theme,
          child: Column(
            children: [
              _buildModernListTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                subtitle: 'How we handle your data',
                onTap: () => _showPrivacyPolicyDialog(),
                theme: theme,
              ),
              const Divider(height: 1),
              _buildModernListTile(
                icon: Icons.description_outlined,
                title: 'Terms & Conditions',
                subtitle: 'Terms of service',
                onTap: () => _showTermsDialog(),
                theme: theme,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppInfoSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('App Info', theme, icon: Icons.info_outlined),
        const SizedBox(height: 16),
        _buildModernCard(
          theme: theme,
          child: _buildModernListTile(
            icon: Icons.mobile_friendly_outlined,
            title: 'About VocalCanvas',
            subtitle: 'Version 1.0.0',
            onTap: () => _showAboutDialog(),
            theme: theme,
          ),
        ),
      ],
    );
  }

  Widget _buildModernListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required ThemeData theme,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    isDestructive
                        ? theme.colorScheme.error.withOpacity(0.1)
                        : theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color:
                    isDestructive
                        ? theme.colorScheme.error
                        : theme.colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isDestructive ? theme.colorScheme.error : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog() {
    if (_currentUser == null) return;

    showDialog(
      context: context,
      builder: (context) => EditProfileDialog(user: _currentUser!),
    ).then((updated) {
      if (updated == true) {
        _loadUserData(); // Refresh user data
      }
    });
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('Change Password'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Current Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: newPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'New Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Confirm New Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (newPasswordController.text !=
                      confirmPasswordController.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Passwords do not match')),
                    );
                    return;
                  }

                  final success = await UserService.updatePassword(
                    currentPasswordController.text,
                    newPasswordController.text,
                  );

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Password updated successfully'
                            : 'Failed to update password',
                      ),
                    ),
                  );
                },
                child: const Text('Update'),
              ),
            ],
          ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text("choose_language".tr()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption('English', 'en', context),
              _buildLanguageOption('हिन्दी', 'hi', context),
              _buildLanguageOption('ಕನ್ನಡ', 'kn', context),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("cancel".tr()),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLanguageOption(
    String title,
    String languageCode,
    BuildContext context,
  ) {
    return ListTile(
      title: Text(title),
      leading: Radio<String>(
        value: languageCode,
        groupValue: context.locale.languageCode,
        onChanged: (String? value) {
          if (value != null) {
            context.setLocale(Locale(value));
            Navigator.of(context).pop();
          }
        },
      ),
      onTap: () {
        context.setLocale(Locale(languageCode));
        Navigator.of(context).pop();
      },
    );
  }

  void _showPrivacyPolicyDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('Privacy Policy'),
            content: const SingleChildScrollView(
              child: Text(
                'Privacy Policy\n\n'
                'At VocalCanvas, we take your privacy seriously. This policy describes how we collect, use, and protect your personal information.\n\n'
                '1. Information We Collect\n'
                '- Account information (name, email, phone)\n'
                '- Profile information and preferences\n'
                '- Audio recordings and content you create\n\n'
                '2. How We Use Your Information\n'
                '- To provide and improve our services\n'
                '- To personalize your experience\n'
                '- To communicate with you about updates\n\n'
                '3. Data Security\n'
                'We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.\n\n'
                'For more information, please contact our support team.',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('Terms & Conditions'),
            content: const SingleChildScrollView(
              child: Text(
                'Terms & Conditions\n\n'
                'Welcome to VocalCanvas. By using our service, you agree to these terms.\n\n'
                '1. Acceptance of Terms\n'
                'By accessing and using VocalCanvas, you accept and agree to be bound by the terms and provision of this agreement.\n\n'
                '2. Use License\n'
                'Permission is granted to temporarily use VocalCanvas for personal, non-commercial transitory viewing only.\n\n'
                '3. Disclaimer\n'
                'The materials on VocalCanvas are provided on an \'as is\' basis. VocalCanvas makes no warranties, expressed or implied.\n\n'
                '4. Limitations\n'
                'In no event shall VocalCanvas or its suppliers be liable for any damages arising out of the use or inability to use VocalCanvas.\n\n'
                '5. Content Responsibility\n'
                'Users are responsible for the content they create and share on the platform.',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('About VocalCanvas'),
            content: const Text(
              'VocalCanvas v1.0.0\n\n'
              'A modern audio-based social platform that lets you express yourself through voice.\n\n'
              'Features:\n'
              '• Voice recordings and stories\n'
              '• Multi-language support\n'
              '• Beautiful, intuitive interface\n'
              '• Secure and private\n\n'
              'Made with ❤️ for voice enthusiasts.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    // Show confirmation dialog first
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('Logout'),
              ),
            ],
          ),
    );

    if (shouldLogout != true) return;

    try {
      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();

      // Also sign out from Google (if used) to clear web/browser Google session
      try {
        final googleSignIn = GoogleSignIn();
        await googleSignIn.signOut();
        try {
          await googleSignIn.disconnect();
        } catch (_) {}
      } catch (_) {}

      // On web try to reduce persistence so a reload doesn't restore auth silently
      if (kIsWeb) {
        try {
          await FirebaseAuth.instance.setPersistence(Persistence.NONE);
        } catch (_) {}
      }

      // Clear saved language preference
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('languageCode');

      // Navigate to AuthPage and remove all previous routes
      Navigator.of(context).pushNamedAndRemoveUntil('/auth', (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error signing out: $e')));
    }
  }
}

// Edit Profile Dialog
class EditProfileDialog extends StatefulWidget {
  final UserModel user;

  const EditProfileDialog({super.key, required this.user});

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _nameEnController;
  late TextEditingController _nameHiController;
  late TextEditingController _nameKnController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _locationEnController;
  late TextEditingController _locationHiController;
  late TextEditingController _locationKnController;
  late TextEditingController _bioEnController;
  late TextEditingController _bioHiController;
  late TextEditingController _bioKnController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _nameEnController = TextEditingController(text: widget.user.name_en);
    _nameHiController = TextEditingController(text: widget.user.name_hi ?? '');
    _nameKnController = TextEditingController(text: widget.user.name_kn ?? '');
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phone ?? '');
    _locationEnController = TextEditingController(
      text: widget.user.location_en ?? '',
    );
    _locationHiController = TextEditingController(
      text: widget.user.location_hi ?? '',
    );
    _locationKnController = TextEditingController(
      text: widget.user.location_kn ?? '',
    );
    _bioEnController = TextEditingController(text: widget.user.bio_en ?? '');
    _bioHiController = TextEditingController(text: widget.user.bio_hi ?? '');
    _bioKnController = TextEditingController(text: widget.user.bio_kn ?? '');
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameEnController.dispose();
    _nameHiController.dispose();
    _nameKnController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationEnController.dispose();
    _locationHiController.dispose();
    _locationKnController.dispose();
    _bioEnController.dispose();
    _bioHiController.dispose();
    _bioKnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Edit Profile',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TabBar(
              controller: _tabController,
              tabs: const [Tab(text: 'Basic Info'), Tab(text: 'Contact & Bio')],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildBasicInfoTab(), _buildContactBioTab()],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveProfile,
                    child:
                        _isLoading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Names (Multilingual)',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _nameEnController,
            label: 'Name (English)',
            icon: Icons.person_outline,
            required: true,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _nameHiController,
            label: 'Name (Hindi) - Optional',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _nameKnController,
            label: 'Name (Kannada) - Optional',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 24),
          Text(
            'Locations (Multilingual)',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _locationEnController,
            label: 'Location (English)',
            icon: Icons.location_on_outlined,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _locationHiController,
            label: 'Location (Hindi) - Optional',
            icon: Icons.location_on_outlined,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _locationKnController,
            label: 'Location (Kannada) - Optional',
            icon: Icons.location_on_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildContactBioTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact Information',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _emailController,
            label: 'Email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            required: true,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _phoneController,
            label: 'Phone Number - Optional',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 24),
          Text(
            'Bio (Multilingual)',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _bioEnController,
            label: 'Bio (English)',
            icon: Icons.description_outlined,
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _bioHiController,
            label: 'Bio (Hindi) - Optional',
            icon: Icons.description_outlined,
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _bioKnController,
            label: 'Bio (Kannada) - Optional',
            icon: Icons.description_outlined,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool required = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (_nameEnController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('English name is required')));
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Email is required')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create updated user model
      final updatedUser = UserModel(
        id: widget.user.id,
        name_en: _nameEnController.text.trim(),
        name_hi:
            _nameHiController.text.trim().isEmpty
                ? null
                : _nameHiController.text.trim(),
        name_kn:
            _nameKnController.text.trim().isEmpty
                ? null
                : _nameKnController.text.trim(),
        email: _emailController.text.trim(),
        phone:
            _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
        location_en:
            _locationEnController.text.trim().isEmpty
                ? null
                : _locationEnController.text.trim(),
        location_hi:
            _locationHiController.text.trim().isEmpty
                ? null
                : _locationHiController.text.trim(),
        location_kn:
            _locationKnController.text.trim().isEmpty
                ? null
                : _locationKnController.text.trim(),
        bio_en:
            _bioEnController.text.trim().isEmpty
                ? null
                : _bioEnController.text.trim(),
        bio_hi:
            _bioHiController.text.trim().isEmpty
                ? null
                : _bioHiController.text.trim(),
        bio_kn:
            _bioKnController.text.trim().isEmpty
                ? null
                : _bioKnController.text.trim(),
        audioUrl: widget.user.audioUrl,
      );

      // Update email in Firebase Auth if changed
      bool emailUpdateSuccess = true;
      if (_emailController.text.trim() != widget.user.email) {
        emailUpdateSuccess = await UserService.updateEmail(
          _emailController.text.trim(),
        );
      }

      // Update user data in Firestore
      final firestoreUpdateSuccess = await UserService.updateUser(updatedUser);

      if (emailUpdateSuccess && firestoreUpdateSuccess) {
        Navigator.pop(context, true); // Return true to indicate success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => _isLoading = false);
  }
}
