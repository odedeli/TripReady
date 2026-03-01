import 'package:flutter/material.dart';
import 'package:tripready/l10n/app_localizations.dart';

export 'package:tripready/l10n/app_localizations.dart';

extension LocalizationExtension on BuildContext {
  AppLocalizations get l => AppLocalizations.of(this);
}
