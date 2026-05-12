import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:folio/core/theme/app_colors.dart';
import 'package:folio/core/theme/app_spacing.dart';

class ReaderToolbar extends StatelessWidget {
  const ReaderToolbar({
    required this.title,
    required this.currentPage,
    required this.totalPages,
    required this.onBack,
    required this.isVisible,
    super.key,
  });

  final String title;
  final int currentPage;
  final int totalPages;
  final VoidCallback onBack;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedSlide(
      offset: isVisible ? Offset.zero : const Offset(0, -1),
      duration: 250.ms,
      curve: isVisible ? Curves.easeOutCubic : Curves.easeInCubic,
      child: AnimatedOpacity(
        opacity: isVisible ? 1 : 0,
        duration: 200.ms,
        child: Container(
          decoration: BoxDecoration(
            color: (isDark ? AppColors.darkBackground : AppColors.lightBackground)
                .withAlpha(230),
            border: Border(
              bottom: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                    tooltip: 'Back',
                  ),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (totalPages > 0)
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: Text(
                        '$currentPage / $totalPages',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.darkTextTertiary
                              : AppColors.lightTextTertiary,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ReaderProgressBar extends StatelessWidget {
  const ReaderProgressBar({
    required this.progress,
    required this.isVisible,
    super.key,
  });

  final double progress;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isVisible ? 1 : 0,
      duration: 200.ms,
      child: LinearProgressIndicator(
        value: progress,
        backgroundColor: Colors.transparent,
        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
        minHeight: 2,
      ),
    );
  }
}
