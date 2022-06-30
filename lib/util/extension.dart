import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

extension AppLocalizatinos on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

extension AppThemes on BuildContext {
  ThemeData get theme => Theme.of(this);
}
