import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:folio/core/models/document.dart';
import 'package:folio/core/router/app_router.dart';
import 'package:folio/core/theme/app_colors.dart';
import 'package:folio/core/theme/app_spacing.dart';
import 'package:folio/features/reader/cubit/reader_cubit.dart';
import 'package:folio/features/reader/widgets/reader_toolbar.dart';
import 'package:open_filex/open_filex.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class ReaderView extends StatefulWidget {
  const ReaderView({required this.document, super.key});

  final Document document;

  @override
  State<ReaderView> createState() => _ReaderViewState();
}

class _ReaderViewState extends State<ReaderView> {
  final _pdfController = PdfViewerController();

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: BlocBuilder<ReaderCubit, ReaderState>(
        builder: (context, state) {
          return Stack(
            children: [
              _buildContent(context, state, isDark),
              Column(
                children: [
                  ReaderToolbar(
                    title: widget.document.name,
                    currentPage: state.currentPage,
                    totalPages: state.totalPages,
                    onBack: context.goHome,
                    isVisible: state.isToolbarVisible,
                  ),
                  ReaderProgressBar(
                    progress: state.readingProgress,
                    isVisible:
                        state.isToolbarVisible && state.totalPages > 0,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ReaderState state,
    bool isDark,
  ) {
    final doc = widget.document;

    if (doc.type == DocumentType.pdf) {
      return _PdfContent(
        path: doc.path,
        controller: _pdfController,
        isDark: isDark,
        onDocumentLoaded: (total) =>
            context.read<ReaderCubit>().onDocumentLoaded(total),
        onPageChanged: (page) =>
            context.read<ReaderCubit>().onPageChanged(page),
        onTap: context.read<ReaderCubit>().toggleToolbar,
        onError: (msg) => context.read<ReaderCubit>().onLoadError(msg),
      );
    }

    // Non-PDF: open with the system viewer
    return _NonPdfPlaceholder(
      document: doc,
      isDark: isDark,
      onOpenExternal: () => OpenFilex.open(doc.path),
    );
  }
}

class _PdfContent extends StatelessWidget {
  const _PdfContent({
    required this.path,
    required this.controller,
    required this.isDark,
    required this.onDocumentLoaded,
    required this.onPageChanged,
    required this.onTap,
    required this.onError,
  });

  final String path;
  final PdfViewerController controller;
  final bool isDark;
  final void Function(int totalPages) onDocumentLoaded;
  final void Function(int page) onPageChanged;
  final VoidCallback onTap;
  final void Function(String message) onError;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SfPdfViewer.file(
        File(path),
        controller: controller,
        canShowScrollHead: false,
        canShowScrollStatus: false,
        canShowPaginationDialog: false,
        pageSpacing: 8,
        onDocumentLoaded: (details) =>
            onDocumentLoaded(details.document.pages.count),
        onPageChanged: (details) => onPageChanged(details.newPageNumber),
        onDocumentLoadFailed: (details) => onError(details.description),
      ),
    );
  }
}

class _NonPdfPlaceholder extends StatelessWidget {
  const _NonPdfPlaceholder({
    required this.document,
    required this.isDark,
    required this.onOpenExternal,
  });

  final Document document;
  final bool isDark;
  final VoidCallback onOpenExternal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.colossal),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: document.type.color.withAlpha(20),
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                border: Border.all(color: document.type.color.withAlpha(40)),
              ),
              child: Icon(document.type.icon, size: 32, color: document.type.color),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              document.name,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${document.type.label} files open in your device\'s default viewer.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),
            FilledButton.icon(
              onPressed: onOpenExternal,
              icon: const Icon(Icons.open_in_new_rounded),
              label: const Text('Open in system viewer'),
            ),
          ],
        ),
      ),
    );
  }
}

