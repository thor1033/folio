import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:folio/core/models/document.dart';
import 'package:folio/core/services/document_service.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._documentService) : super(const HomeState());

  final DocumentService _documentService;

  void loadDocuments() {
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      final docs = _documentService.loadRecent();
      emit(state.copyWith(status: HomeStatus.success, documents: docs));
    } catch (_) {
      emit(state.copyWith(status: HomeStatus.failure));
    }
  }

  Future<Document?> pickDocument() async {
    try {
      final doc = await _documentService.pickDocument();
      if (doc != null) {
        final updated = [doc, ...state.documents.where((d) => d.path != doc.path)];
        emit(state.copyWith(documents: updated, status: HomeStatus.success));
      }
      return doc;
    } catch (_) {
      return null;
    }
  }

  Future<void> removeDocument(String id) async {
    await _documentService.removeRecent(id);
    final updated = state.documents.where((d) => d.id != id).toList();
    emit(state.copyWith(documents: updated));
  }

  Future<void> clearAll() async {
    await _documentService.clearRecent();
    emit(state.copyWith(documents: []));
  }

  void search(String query) {
    emit(state.copyWith(searchQuery: query));
  }
}
