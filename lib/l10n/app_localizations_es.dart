// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

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
