import 'package:flutter/material.dart';

/// Design tokens aligned with "The Quiet Ceremony" Japandi system.
/// Spacing uses a 4px grid. Shapes use soft, organic radii.
class UIConstants {
  // ─── Animation (Section 14) ───
  static const Duration animationDuration = Duration(milliseconds: 200);
  static const Duration shortAnimationDuration = Duration(milliseconds: 150);
  static const Duration entranceAnimationDuration = Duration(milliseconds: 300);
  static const Curve defaultCurve = Curves.easeInOutCubic; // cubic-bezier(0.4, 0, 0.2, 1)

  // ─── Duration limits (app logic) ───
  static const double minImageDuration = 1.0;
  static const double maxImageDuration = 30.0;
  static const double minTransitionDuration = 0.1;
  static const double maxTransitionDuration = 1.0;

  // ─── Shape: Organic radii (Section 5) ───
  static const double cardBorderRadius = 8.0;     // rounded-sm (0.5rem)
  static const double appBarBorderRadius = 0.0;    // flat, no rounding — Japandi
  static const double buttonBorderRadius = 9999.0; // pill/full — "The Hearth"
  static const double dialogBorderRadius = 8.0;
  static const double inputBorderRadius = 8.0;
  static const double iconBorderRadius = 8.0;

  // ─── Spacing Scale (Section 7, 4px grid) ───
  static const double space2 = 8.0;
  static const double space3 = 12.0;
  static const double space4 = 16.0;
  static const double space5 = 20.0;
  static const double space6 = 24.0;
  static const double space8 = 32.0;
  static const double space10 = 40.0;
  static const double space12 = 48.0;
  static const double space16 = 64.0;
  static const double space20 = 80.0;

  // ─── Padding Presets ───
  static const EdgeInsets defaultPadding = EdgeInsets.all(space4);
  static const EdgeInsets cardPadding = EdgeInsets.all(space6);
  static const EdgeInsets sectionPadding = EdgeInsets.symmetric(
    horizontal: space4, vertical: space8,
  );
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: space6, vertical: space4,
  );

  // ─── Image quality ───
  static const double imageQuality = 100;

  // ─── File validation ───
  static const int minFileSize = 1000; // bytes
}
