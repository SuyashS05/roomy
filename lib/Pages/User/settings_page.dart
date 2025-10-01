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
      appBar: AppBar(title: Text('settings'.tr())),
      body: Column(
        children: [
          ListTile(
            title: Text('dark_mode'.tr()),
            trailing: Switch(
              value: themeProvider.themeMode == ThemeMode.dark,
              onChanged: (_) => themeProvider.toggleTheme(),
            ),
          ),
          ListTile(
            title: Text('language'.tr()),
            trailing: DropdownButton<Locale>(
              value: localeProvider.locale,
              items: const [
                DropdownMenuItem(value: Locale('en'), child: Text("English")),
                DropdownMenuItem(value: Locale('hi'), child: Text("हिंदी")),
                DropdownMenuItem(value: Locale('mr'), child: Text("मराठी")),
              ],
              onChanged: (val) {
                if (val != null) {
                  localeProvider.setLocale(context, val); // updates EasyLocalization
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
