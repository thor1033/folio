import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:folio/core/services/document_service.dart';
import 'package:folio/features/home/cubit/home_cubit.dart';
import 'package:folio/features/home/view/home_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return BlocProvider(
          create: (_) => HomeCubit(DocumentService(snapshot.data!))
            ..loadDocuments(),
          child: const HomeView(),
        );
      },
    );
  }
}
