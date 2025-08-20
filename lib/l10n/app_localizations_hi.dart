// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get welcomeMessage => 'स्वागत है';

  @override
  String get loginButton => 'लॉग इन';

  @override
  String get signupButton => 'साइन अप';

  @override
  String get settingsTitle => 'सेटिंग्स';

  @override
  String get darkMode => 'डार्क मोड';

  @override
  String get language => 'भाषा';

  @override
  String get chooseLanguage => 'अपनी भाषा चुनें';

  @override
  String get searchHint => 'खोजें';

  @override
  String get emailHint => 'ईमेल';

  @override
  String get passwordHint => 'पासवर्ड';

  @override
  String get nameHint => 'नाम';

  @override
  String get phoneHint => 'फोन';

  @override
  String get cancel => 'रद्द करें';
}
