import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:folio/core/models/document.dart';
import 'package:folio/core/services/document_service.dart';
import 'package:folio/features/reader/cubit/reader_cubit.dart';
import 'package:folio/features/reader/view/reader_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReaderPage extends StatelessWidget {
  const ReaderPage({required this.document, super.key});

  final Document document;

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
          create: (_) => ReaderCubit(
            DocumentService(snapshot.data!),
            document,
          ),
          child: ReaderView(document: document),
        );
      },
    );
  }
}
