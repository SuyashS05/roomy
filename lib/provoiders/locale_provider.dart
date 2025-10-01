import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en'); // default
  Locale get locale => _locale;

  void setLocale(BuildContext context, Locale locale) {
    _locale = locale;
    EasyLocalization.of(context)?.setLocale(locale); // important
    notifyListeners();
  }
}
