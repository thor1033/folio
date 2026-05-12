import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:folio/core/theme/app_colors.dart';
import 'package:folio/core/theme/app_spacing.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({required this.onOpenFile, super.key});

  final VoidCallback onOpenFile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.colossal),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.lightSurfaceVariant,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              ),
              child: Icon(
                Icons.folder_open_outlined,
                size: 36,
                color: isDark
                    ? AppColors.darkTextTertiary
                    : AppColors.lightTextTertiary,
              ),
            )
                .animate()
                .scale(
                  duration: 500.ms,
                  curve: Curves.easeOutBack,
                  begin: const Offset(0.8, 0.8),
                )
                .fadeIn(duration: 400.ms),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              'No documents yet',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            )
                .animate()
                .fadeIn(delay: 100.ms, duration: 400.ms)
                .slideY(
                  begin: 0.1,
                  end: 0,
                  delay: 100.ms,
                  duration: 400.ms,
                  curve: Curves.easeOut,
                ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Open a PDF, Word, PowerPoint or\nExcel file to get started.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            )
                .animate()
                .fadeIn(delay: 150.ms, duration: 400.ms),
            const SizedBox(height: AppSpacing.xxxl),
            FilledButton.icon(
              onPressed: onOpenFile,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Open file'),
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 400.ms)
                .scale(
                  delay: 200.ms,
                  duration: 400.ms,
                  curve: Curves.easeOutBack,
                  begin: const Offset(0.9, 0.9),
                ),
          ],
        ),
      ),
    );
  }
}
