import 'package:flutter/material.dart';

import 'app_semantic_colors.dart';

/// Akses singkat ke tema dari widget mana pun (termasuk ConsumerWidget).
extension ThemeContext on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  AppSemanticColors get semanticColors =>
      Theme.of(this).extension<AppSemanticColors>() ?? AppSemanticColors.light;
}
