import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reading_sms/src/models/search_models.dart';
import 'package:reading_sms/src/presentation/cubit/search_state.dart';
import 'package:reading_sms/src/repository/sms_repository.dart';

class SearchCubit extends Cubit<SearchState> {
  final SmsRepository _repository;

  // Search history (limited to 10 recent searches)
  final List<SearchHistoryItem> _searchHistory = [];

  SearchCubit({required SmsRepository repository})
    : _repository = repository,
      super(const SearchInitial());

  List<SearchHistoryItem> get searchHistory =>
      List.unmodifiable(_searchHistory);

  /// Perform search for contact names only (no duplicates)
  Future<void> search(String query, {SearchFilters? filters}) async {
    if (query.trim().isEmpty) {
      emit(const SearchInitial());
      return;
    }

    emit(const SearchLoading());

    try {
      // Fetch all conversations
      final conversations = await _repository.fetchConversations();

      final lowerQuery = query.toLowerCase();

      // Filter conversations by contact name match
      final matchedConversations = conversations.where((conversation) {
        // Search in contact name (displayName) only
        final displayName = conversation.displayName.toLowerCase();
        final phoneNumber = conversation.phoneNumber.toLowerCase();

        // Match against display name or phone number
        return displayName.contains(lowerQuery) ||
            phoneNumber.contains(lowerQuery);
      }).toList();

      // Sort by most recent message first
      matchedConversations.sort((a, b) => b.lastDate.compareTo(a.lastDate));

      // Convert to SearchResult format (one result per conversation)
      final List<SearchResult> results = [];
      for (var conversation in matchedConversations) {
        // Get the most recent message for this conversation
        final messages = await _repository.fetchMessagesByContact(
          conversation.phoneNumber,
        );

        if (messages.isNotEmpty) {
          // Use the most recent message
          final mostRecentMessage = messages.last;

          results.add(
            SearchResult(
              message: mostRecentMessage,
              conversation: conversation,
              matchPositions: _findMatchPositions(
                conversation.displayName,
                query,
              ),
            ),
          );
        }
      }

      // Group by contact (should be 1 per contact since we're not duplicating)
      final Map<String, int> groupedByContact = {};
      for (var result in results) {
        final phone = result.conversation.phoneNumber;
        groupedByContact[phone] = 1; // Always 1 since no duplicates
      }

      // Add to search history
      _addToHistory(query, results.length);

      emit(
        SearchLoaded(
          results: results,
          query: query,
          filters: filters ?? const SearchFilters(),
          groupedByContact: groupedByContact,
        ),
      );
    } catch (e) {
      emit(SearchError('Failed to search: $e'));
    }
  }

  /// Quick search with debouncing support (for real-time search)
  Future<void> quickSearch(String query) async {
    await search(query);
  }

  /// Clear search results
  void clearSearch() {
    emit(const SearchInitial());
  }

  /// Get search suggestions based on history
  List<String> getSearchSuggestions(String partial) {
    if (partial.isEmpty) {
      return _searchHistory.map((h) => h.query).take(5).toList();
    }

    return _searchHistory
        .where((h) => h.query.toLowerCase().contains(partial.toLowerCase()))
        .map((h) => h.query)
        .take(5)
        .toList();
  }

  /// Clear search history
  void clearHistory() {
    _searchHistory.clear();
  }

  /// Helper: Find positions where query matches in text
  List<int> _findMatchPositions(String text, String query) {
    final List<int> positions = [];
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();

    int startIndex = 0;
    while (true) {
      final index = lowerText.indexOf(lowerQuery, startIndex);
      if (index == -1) break;
      positions.add(index);
      startIndex = index + query.length;
    }

    return positions;
  }

  /// Helper: Add search to history
  void _addToHistory(String query, int resultCount) {
    // Remove if already exists
    _searchHistory.removeWhere((item) => item.query == query);

    // Add to beginning
    _searchHistory.insert(
      0,
      SearchHistoryItem(
        query: query,
        timestamp: DateTime.now(),
        resultCount: resultCount,
      ),
    );

    // Keep only last 10
    if (_searchHistory.length > 10) {
      _searchHistory.removeLast();
    }
  }
}
