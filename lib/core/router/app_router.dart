import 'package:flutter/material.dart';
import 'package:folio/core/models/document.dart';
import 'package:folio/features/home/view/home_page.dart';
import 'package:folio/features/reader/view/reader_page.dart';
import 'package:folio/features/settings/view/settings_page.dart';
import 'package:go_router/go_router.dart';

abstract final class AppRoutes {
  static const home = '/';
  static const reader = '/reader';
  static const settings = '/settings';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  debugLogDiagnostics: false,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      builder: (_, __) => const HomePage(),
    ),
    GoRoute(
      path: AppRoutes.reader,
      builder: (context, state) {
        final doc = state.extra as Document;
        return ReaderPage(document: doc);
      },
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (_, __) => const SettingsPage(),
    ),
  ],
);

extension AppNavigation on BuildContext {
  void openDocument(Document doc) =>
      go(AppRoutes.reader, extra: doc);

  void goHome() => go(AppRoutes.home);

  void goSettings() => go(AppRoutes.settings);
}
