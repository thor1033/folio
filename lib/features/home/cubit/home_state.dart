part of 'home_cubit.dart';

enum HomeStatus { initial, loading, success, failure }

final class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.documents = const [],
    this.searchQuery = '',
  });

  final HomeStatus status;
  final List<Document> documents;
  final String searchQuery;

  List<Document> get filteredDocuments {
    if (searchQuery.isEmpty) return documents;
    final q = searchQuery.toLowerCase();
    return documents.where((d) => d.name.toLowerCase().contains(q)).toList();
  }

  HomeState copyWith({
    HomeStatus? status,
    List<Document>? documents,
    String? searchQuery,
  }) {
    return HomeState(
      status: status ?? this.status,
      documents: documents ?? this.documents,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object> get props => [status, documents, searchQuery];
}
