import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class LocalizationProvider with ChangeNotifier {
  Locale _locale;

  LocalizationProvider([Locale? initial]) : _locale = initial ?? const Locale('en');

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (!EasyLocalization.of(GlobalKey<NavigatorState>().currentContext!)!.supportedLocales.contains(locale)) return;
    _locale = locale;
    notifyListeners();
  }
}
