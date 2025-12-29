import 'package:equatable/equatable.dart';
import 'package:reading_sms/src/models/search_models.dart';

/// Base state for search operations
abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class SearchInitial extends SearchState {
  const SearchInitial();
}

/// Searching state
class SearchLoading extends SearchState {
  const SearchLoading();
}

/// Search results loaded
class SearchLoaded extends SearchState {
  final List<SearchResult> results;
  final String query;
  final SearchFilters filters;
  final Map<String, int> groupedByContact; // Contact phone -> message count

  const SearchLoaded({
    required this.results,
    required this.query,
    required this.filters,
    required this.groupedByContact,
  });

  int get totalResults => results.length;

  bool get hasResults => results.isNotEmpty;

  @override
  List<Object?> get props => [results, query, filters, groupedByContact];
}

/// Search error
class SearchError extends SearchState {
  final String message;

  const SearchError(this.message);

  @override
  List<Object?> get props => [message];
}
