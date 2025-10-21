// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'App Template';

  @override
  String welcomeMessage(String appName) {
    return 'Welcome to $appName!';
  }

  @override
  String get loginButton => 'Log In';

  @override
  String get signUpButton => 'Sign Up';
}
