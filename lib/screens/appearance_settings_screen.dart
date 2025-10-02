import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rasoi_app/providers/theme_provider.dart';

class AppearanceSettingsScreen extends StatelessWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Appearance',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Text(
            'Select the theme for the application.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildThemeOption(context, 'Light', Icons.wb_sunny, ThemeMode.light, themeProvider),
              const SizedBox(width: 10),
              _buildThemeOption(context, 'Dark', Icons.mode_night, ThemeMode.dark, themeProvider),
              const SizedBox(width: 10),
              _buildThemeOption(context, 'System', Icons.desktop_windows, ThemeMode.system, themeProvider),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(BuildContext context, String title, IconData icon, ThemeMode mode, ThemeProvider themeProvider) {
    final isSelected = themeProvider.themeMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          themeProvider.setThemeMode(mode);
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? Colors.deepOrange.shade50 : Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? Colors.deepOrange : Colors.transparent),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.deepOrange : Colors.grey[700]),
              const SizedBox(height: 5),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.deepOrange : Colors.grey[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
