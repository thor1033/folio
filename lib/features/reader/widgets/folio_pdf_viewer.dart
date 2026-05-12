import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:folio/core/services/folio_pdf_renderer.dart';
import 'package:folio/core/theme/app_colors.dart';
import 'package:folio/core/theme/app_spacing.dart';

class FolioPdfViewer extends StatefulWidget {
  const FolioPdfViewer({
    required this.path,
    required this.onDocumentLoaded,
    required this.onPageChanged,
    required this.onTap,
    required this.onError,
    super.key,
  });

  final String path;
  final void Function(int totalPages) onDocumentLoaded;
  final void Function(int page) onPageChanged;
  final VoidCallback onTap;
  final void Function(String error) onError;

  @override
  State<FolioPdfViewer> createState() => _FolioPdfViewerState();
}

class _FolioPdfViewerState extends State<FolioPdfViewer> {
  final _renderer = FolioPdfRenderer();
  final _scrollController = ScrollController();

  int _pageCount = 0;
  int _currentPage = 1;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_trackPage);
    _openDocument();
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_trackPage)
      ..dispose();
    _renderer.closeDocument();
    super.dispose();
  }

  Future<void> _openDocument() async {
    try {
      final count = await _renderer.openDocument(widget.path);
      if (!mounted) return;
      setState(() {
        _pageCount = count;
        _loading = false;
      });
      widget.onDocumentLoaded(count);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
      widget.onError(e.toString());
    }
  }

  void _trackPage() {
    if (!_scrollController.hasClients || _pageCount == 0) return;
    // Approximate page from scroll offset — each page is roughly screen height
    final screenH = MediaQuery.of(context).size.height;
    final page = (_scrollController.offset / screenH).floor() + 1;
    final clamped = page.clamp(1, _pageCount);
    if (clamped != _currentPage) {
      _currentPage = clamped;
      widget.onPageChanged(clamped);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _ErrorView(message: _error!);
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _pageCount,
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) => _PdfPage(
          key: ValueKey(index),
          index: index,
          renderer: _renderer,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _PdfPage extends StatefulWidget {
  const _PdfPage({
    required this.index,
    required this.renderer,
    super.key,
  });

  final int index;
  final FolioPdfRenderer renderer;

  @override
  State<_PdfPage> createState() => _PdfPageState();
}

class _PdfPageState extends State<_PdfPage> {
  Uint8List? _bytes;
  bool _rendering = true;

  @override
  void initState() {
    super.initState();
    // Defer one frame so layout provides a valid size via MediaQuery
    WidgetsBinding.instance.addPostFrameCallback((_) => _render());
  }

  Future<void> _render() async {
    if (!mounted) return;
    try {
      final query = MediaQuery.of(context);
      // Render at physical pixels for crisp display on all densities
      final physicalWidth = (query.size.width * query.devicePixelRatio).toInt();
      final bytes = await widget.renderer.renderPage(
        index: widget.index,
        width: physicalWidth,
      );
      if (!mounted) return;
      setState(() {
        _bytes = bytes;
        _rendering = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _rendering = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_rendering || _bytes == null) {
      return AspectRatio(
        aspectRatio: 0.707, // A4 placeholder while loading
        child: ColoredBox(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurfaceVariant,
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return InteractiveViewer(
      panEnabled: false, // ListView handles vertical scroll
      scaleEnabled: true,
      minScale: 1,
      maxScale: 4,
      child: Image.memory(
        _bytes!,
        fit: BoxFit.fitWidth,
        gaplessPlayback: true,
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Failed to load PDF',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark
                    ? AppColors.darkTextTertiary
                    : AppColors.lightTextTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
