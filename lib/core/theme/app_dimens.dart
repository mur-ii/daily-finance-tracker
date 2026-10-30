import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Skala spacing 8pt.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

/// Radius sudut komponen. Neo-brutalism: kaku, maksimal 4px.
abstract final class AppRadius {
  static const double sm = 4;

  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const RoundedRectangleBorder smShape = RoundedRectangleBorder(
    borderRadius: smAll,
    side: AppNeo.side,
  );
}

/// Border tebal dan hard shadow neo-brutalism.
abstract final class AppNeo {
  static const double borderWidth = 2;
  static const double focusBorderWidth = 3;

  /// Offset hard shadow; tombol turun sejauh ini saat ditekan.
  static const Offset shadowOffset = Offset(4, 4);

  static const BorderSide side = BorderSide(
    color: AppColors.ink,
    width: borderWidth,
  );
  static const Border border = Border.fromBorderSide(side);

  static const List<BoxShadow> shadow = [
    BoxShadow(color: AppColors.ink, offset: shadowOffset),
  ];
}
