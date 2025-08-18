// SettingsScreen
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0EBE3),
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFFF0EBE3),
        elevation: 0,
        foregroundColor: const Color(0xFF002924),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          // Account Section
          const Text(
            'Account',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF002924),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.person, color: Color(0xFF002924)),
            title: const Text('Edit Profile'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Color(0xFF002924)),
            title: const Text('Logout'),
            onTap: () {},
          ),
          const Divider(height: 32),

          // Theme Section
          const Text(
            'Theme',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF002924),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.brightness_6, color: Color(0xFF002924)),
            title: const Text('Dark Mode'),
            trailing: Switch(value: false, onChanged: (val) {}),
          ),
          const Divider(height: 32),

          // App Info Section
          const Text(
            'App Info',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF002924),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Color(0xFF002924)),
            title: const Text('About VocalCanvas'),
            subtitle: const Text('Version 1.0.0'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
