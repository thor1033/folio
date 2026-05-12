import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:folio/core/router/app_router.dart';
import 'package:folio/core/theme/app_theme.dart';
import 'package:folio/features/settings/cubit/settings_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        return BlocProvider(
          create: (_) => SettingsCubit(snapshot.data!),
          child: BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, settings) {
              return MaterialApp.router(
                title: 'Folio',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light,
                darkTheme: AppTheme.dark,
                themeMode: settings.themeMode,
                routerConfig: appRouter,
              );
            },
          ),
        );
      },
    );
  }
}
