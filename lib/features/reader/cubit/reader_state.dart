part of 'reader_cubit.dart';

enum ReaderStatus { initial, loading, success, failure }

final class ReaderState extends Equatable {
  const ReaderState({
    this.status = ReaderStatus.initial,
    this.currentPage = 1,
    this.totalPages = 0,
    this.isToolbarVisible = true,
    this.zoomLevel = 1,
    this.errorMessage,
  });

  final ReaderStatus status;
  final int currentPage;
  final int totalPages;
  final bool isToolbarVisible;
  final double zoomLevel;
  final String? errorMessage;

  double get readingProgress =>
      totalPages > 0 ? currentPage / totalPages : 0;

  ReaderState copyWith({
    ReaderStatus? status,
    int? currentPage,
    int? totalPages,
    bool? isToolbarVisible,
    double? zoomLevel,
    String? errorMessage,
  }) {
    return ReaderState(
      status: status ?? this.status,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      isToolbarVisible: isToolbarVisible ?? this.isToolbarVisible,
      zoomLevel: zoomLevel ?? this.zoomLevel,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        currentPage,
        totalPages,
        isToolbarVisible,
        zoomLevel,
        errorMessage,
      ];
}
