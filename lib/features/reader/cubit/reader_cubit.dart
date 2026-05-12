import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:folio/core/models/document.dart';
import 'package:folio/core/services/document_service.dart';

part 'reader_state.dart';

class ReaderCubit extends Cubit<ReaderState> {
  ReaderCubit(this._documentService, this.document) : super(const ReaderState());

  final DocumentService _documentService;
  final Document document;

  void onDocumentLoaded(int totalPages) {
    emit(
      state.copyWith(
        status: ReaderStatus.success,
        totalPages: totalPages,
        currentPage: 1,
      ),
    );
    _documentService.saveRecent(
      document.copyWith(totalPages: totalPages, lastOpened: DateTime.now()),
    );
  }

  void onPageChanged(int page) {
    emit(state.copyWith(currentPage: page));
  }

  void toggleToolbar() {
    emit(state.copyWith(isToolbarVisible: !state.isToolbarVisible));
  }

  void showToolbar() {
    if (!state.isToolbarVisible) {
      emit(state.copyWith(isToolbarVisible: true));
    }
  }

  void onLoadError(String message) {
    emit(state.copyWith(status: ReaderStatus.failure, errorMessage: message));
  }
}
