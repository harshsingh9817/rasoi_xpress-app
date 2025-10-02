import 'package:flutter/material.dart';
import 'package:rasoi_app/screens/account_settings_screen.dart';
import 'package:rasoi_app/screens/appearance_settings_screen.dart';
import 'package:rasoi_app/screens/help_screen.dart'; // Import HelpScreen

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const AccountSettingsScreen(),
          const SizedBox(height: 20),
          const AppearanceSettingsScreen(),
          const SizedBox(height: 20),
          // Help Section
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('Help & Support'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpScreen()));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
