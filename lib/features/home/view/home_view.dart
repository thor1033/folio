import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:folio/core/router/app_router.dart';
import 'package:folio/core/theme/app_colors.dart';
import 'package:folio/core/theme/app_spacing.dart';
import 'package:folio/features/home/cubit/home_cubit.dart';
import 'package:folio/features/home/widgets/document_card.dart';
import 'package:folio/features/home/widgets/empty_state.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _FolioAppBar(
            isDark: isDark,
            onSettings: context.goSettings,
            onOpenFile: _openFile,
          ),
          _SearchBar(
            controller: _searchController,
            isDark: isDark,
            onChanged: context.read<HomeCubit>().search,
          ),
          BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              if (state.status == HomeStatus.loading) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final docs = state.filteredDocuments;

              if (docs.isEmpty) {
                return SliverFillRemaining(
                  child: EmptyState(onOpenFile: _openFile),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.massive,
                ),
                sliver: SliverList.separated(
                  itemCount: docs.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, i) {
                    final doc = docs[i];
                    return DocumentCard(
                      key: ValueKey(doc.id),
                      document: doc,
                      index: i,
                      onTap: () => context.openDocument(doc),
                      onDelete: () =>
                          context.read<HomeCubit>().removeDocument(doc.id),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state.documents.isEmpty) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: _openFile,
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add_rounded),
            label: const Text(
              'Open file',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          )
              .animate()
              .scale(
                duration: 400.ms,
                curve: Curves.easeOutBack,
                begin: const Offset(0.8, 0.8),
              )
              .fadeIn(duration: 300.ms);
        },
      ),
    );
  }

  Future<void> _openFile() async {
    final doc = await context.read<HomeCubit>().pickDocument();
    if (doc != null && mounted) {
      context.openDocument(doc);
    }
  }
}

class _FolioAppBar extends StatelessWidget {
  const _FolioAppBar({
    required this.isDark,
    required this.onSettings,
    required this.onOpenFile,
  });

  final bool isDark;
  final VoidCallback onSettings;
  final VoidCallback onOpenFile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SliverAppBar(
      floating: true,
      snap: true,
      pinned: false,
      titleSpacing: AppSpacing.lg,
      title: Text(
        'Folio',
        style: theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        ),
      ),
      actions: [
        IconButton(
          onPressed: onSettings,
          icon: const Icon(Icons.settings_outlined),
          tooltip: 'Settings',
        ),
        const SizedBox(width: AppSpacing.xs),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.isDark,
    required this.onChanged,
  });

  final TextEditingController controller;
  final bool isDark;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.xs,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: SearchBar(
          controller: controller,
          hintText: 'Search documents…',
          leading: Icon(
            Icons.search_rounded,
            color:
                isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
          ),
          trailing: [
            if (controller.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 18),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              ),
          ],
          onChanged: onChanged,
          backgroundColor: WidgetStatePropertyAll(
            isDark ? AppColors.darkSurface : AppColors.lightSurface,
          ),
          shadowColor: const WidgetStatePropertyAll(Colors.transparent),
          side: WidgetStatePropertyAll(
            BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
          elevation: const WidgetStatePropertyAll(0),
        ),
      ),
    );
  }
}
