import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Theme settings
            ListTile(
              title: const Text('Theme'),
              trailing: DropdownButton<String>(
                value: appProvider.themeMode,
                items: const [
                  DropdownMenuItem(value: 'system', child: Text('System')),
                  DropdownMenuItem(value: 'light', child: Text('Light')),
                  DropdownMenuItem(value: 'dark', child: Text('Dark')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    appProvider.setThemeMode(value);
                  }
                },
              ),
            ),
            // Language settings
            ListTile(
              title: const Text('Language'),
              trailing: DropdownButton<String>(
                value: appProvider.currentLanguage,
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'ar', child: Text('Arabic')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    appProvider.setLanguage(value);
                  }
                },
              ),
            ),
            // Font size settings
            ListTile(
              title: const Text('Font Size'),
              subtitle: Slider(
                value: appProvider.fontSize,
                min: 18,
                max: 40,
                divisions: 11,
                label: appProvider.fontSize.round().toString(),
                onChanged: (value) {
                  appProvider.setFontSize(value);
                },
              ),
            ),
            // Show translation settings
            SwitchListTile(
              title: const Text('Show Translation'),
              value: appProvider.showTranslation,
              onChanged: (value) {
                appProvider.setShowTranslation(value);
              },
            ),
            // Show tafsir settings
            SwitchListTile(
              title: const Text('Show Tafsir'),
              value: appProvider.showTafsir,
              onChanged: (value) {
                appProvider.setShowTafsir(value);
              },
            ),
            // Reciter settings
            ListTile(
              title: const Text('Reciter'),
              trailing: DropdownButton<String>(
                value: appProvider.reciter,
                items: appProvider.reciters.map((reciter) {
                  return DropdownMenuItem(
                    value: reciter.id,
                    child: Text(reciter.name),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    appProvider.setReciter(value);
                  }
                },
              ),
            ),
            const Divider(),
            // Notification settings
            SwitchListTile(
              title: const Text('Daily Reading Reminder'),
              value: appProvider.dailyReminder,
              onChanged: (value) {
                appProvider.setDailyReminder(value);
              },
            ),
            SwitchListTile(
              title: const Text('Prayer Time Notifications'),
              value: appProvider.prayerNotifications,
              onChanged: (value) {
                appProvider.setPrayerNotifications(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}
