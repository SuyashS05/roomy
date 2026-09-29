import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:romy/provoiders/locale_provider.dart';
import 'package:romy/provoiders/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('settings'.tr()),
        centerTitle: true,
        elevation: 2,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 🔹 Appearance Section
          Text(
            'appearance'.tr(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
          ),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            child: ListTile(
              leading: const Icon(Icons.brightness_6, color: Colors.blueAccent),
              title: Text('dark_mode'.tr()),
              trailing: Switch(
                value: themeProvider.themeMode == ThemeMode.dark,
                onChanged: (_) => Provider.of<ThemeProvider>(context, listen: false).toggleTheme(),
                activeColor: Colors.blueAccent,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 🔹 Language Section
          Text(
            'language_settings'.tr(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
          ),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            child: ListTile(
              leading: const Icon(Icons.language, color: Colors.orangeAccent),
              title: Text('language'.tr()),
              trailing: DropdownButton<Locale>(
                value: localeProvider.locale,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: Locale('en'), child: Text("English")),
                  DropdownMenuItem(value: Locale('hi'), child: Text("हिंदी")),
                  DropdownMenuItem(value: Locale('mr'), child: Text("मराठी")),
                ],
                onChanged: (val) {
                  if (val != null) {
                    localeProvider.setLocale(context, val);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 🔹 About / Info Section
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.green),
              title: Text('about'.tr()),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'Roomy',
                  applicationVersion: '1.0.0',
                  applicationIcon: const Icon(Icons.home_filled, size: 40, color: Colors.blue),
                  children: [
                    Text('about_app_description'.tr()),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}



/*
onChanged: (val) async {
  if (val != null) {
    // Update local provider
    localeProvider.setLocale(context, val);

    // Update Firestore
    final user = context.read<UserDetailsProvider>().user;
    if (user != null) {
      final updatedUser = user.copyWith(language: val.languageCode);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(updatedUser.toMap(), SetOptions(merge: true));

      // Update provider so UI reflects Firestore change if needed
      context.read<UserDetailsProvider>().updateUser(updatedUser);
    }
  }
},
*/