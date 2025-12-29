import 'package:equatable/equatable.dart';
import 'package:reading_sms/src/models/models.dart';

/// Search result that includes the matched message and conversation context
class SearchResult extends Equatable {
  final SmsMessage message;
  final SmsConversation conversation;
  final List<int> matchPositions; // Positions where search query matches

  const SearchResult({
    required this.message,
    required this.conversation,
    this.matchPositions = const [],
  });

  @override
  List<Object?> get props => [message, conversation, matchPositions];
}

/// Search filters for advanced search
class SearchFilters extends Equatable {
  final DateTime? startDate;
  final DateTime? endDate;
  final bool? sentOnly; // true = sent, false = received, null = all
  final String? contactFilter; // Filter by specific contact
  final int? minLength; // Minimum message length

  const SearchFilters({
    this.startDate,
    this.endDate,
    this.sentOnly,
    this.contactFilter,
    this.minLength,
  });

  bool get hasFilters =>
      startDate != null ||
      endDate != null ||
      sentOnly != null ||
      contactFilter != null ||
      minLength != null;

  SearchFilters copyWith({
    DateTime? startDate,
    DateTime? endDate,
    bool? sentOnly,
    String? contactFilter,
    int? minLength,
    bool clearStartDate = false,
    bool clearEndDate = false,
    bool clearSentOnly = false,
    bool clearContactFilter = false,
    bool clearMinLength = false,
  }) {
    return SearchFilters(
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      sentOnly: clearSentOnly ? null : (sentOnly ?? this.sentOnly),
      contactFilter: clearContactFilter
          ? null
          : (contactFilter ?? this.contactFilter),
      minLength: clearMinLength ? null : (minLength ?? this.minLength),
    );
  }

  @override
  List<Object?> get props => [
    startDate,
    endDate,
    sentOnly,
    contactFilter,
    minLength,
  ];
}

/// Search history item
class SearchHistoryItem extends Equatable {
  final String query;
  final DateTime timestamp;
  final int resultCount;

  const SearchHistoryItem({
    required this.query,
    required this.timestamp,
    required this.resultCount,
  });

  @override
  List<Object?> get props => [query, timestamp, resultCount];
}
