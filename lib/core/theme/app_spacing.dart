// Spacing scale on an 8px base grid with golden-ratio inflection points.
abstract final class AppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 40;
  static const double massive = 48;
  static const double colossal = 64;

  // Touch targets — Fitts's Law minimum 48dp
  static const double minTouchTarget = 48;

  // Corner radii
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 20;
  static const double radiusFull = 999;

  // Card / sheet dimensions
  static const double cardElevation = 0;
  static const double sheetMaxWidth = 480;
}
