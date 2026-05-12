import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:folio/core/models/document.dart';
import 'package:folio/core/router/app_router.dart';
import 'package:folio/core/theme/app_colors.dart';
import 'package:folio/core/theme/app_spacing.dart';
import 'package:folio/features/reader/cubit/reader_cubit.dart';
import 'package:folio/features/reader/widgets/folio_pdf_viewer.dart';
import 'package:folio/features/reader/widgets/reader_toolbar.dart';
import 'package:open_filex/open_filex.dart';

class ReaderView extends StatelessWidget {
  const ReaderView({required this.document, super.key});

  final Document document;

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
              _buildContent(context, isDark),
              Column(
                children: [
                  ReaderToolbar(
                    title: document.name,
                    currentPage: state.currentPage,
                    totalPages: state.totalPages,
                    onBack: context.goHome,
                    isVisible: state.isToolbarVisible,
                  ),
                  ReaderProgressBar(
                    progress: state.readingProgress,
                    isVisible: state.isToolbarVisible && state.totalPages > 0,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isDark) {
    if (document.type == DocumentType.pdf) {
      return FolioPdfViewer(
        path: document.path,
        onDocumentLoaded: context.read<ReaderCubit>().onDocumentLoaded,
        onPageChanged: context.read<ReaderCubit>().onPageChanged,
        onTap: context.read<ReaderCubit>().toggleToolbar,
        onError: context.read<ReaderCubit>().onLoadError,
      );
    }

    return _NonPdfPlaceholder(
      document: document,
      isDark: isDark,
      onOpenExternal: () => OpenFilex.open(document.path),
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
              "${document.type.label} files open in your device's default viewer.",
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
