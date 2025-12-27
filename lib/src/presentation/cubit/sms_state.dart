import 'package:equatable/equatable.dart';

/// Base state for SMS operations
abstract class SmsState extends Equatable {
  const SmsState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any operation
class SmsInitial extends SmsState {
  const SmsInitial();
}

/// Loading state during data fetch
class SmsLoading extends SmsState {
  const SmsLoading();
}

/// Success state with conversations data
class ConversationsLoaded extends SmsState {

  const ConversationsLoaded();

  @override
  List<Object?> get props => [];
}

/// Success state with messages data
class MessagesLoaded extends SmsState {

  const MessagesLoaded();

  @override
  List<Object?> get props => [];
}

/// Error state with error message
class SmsError extends SmsState {
  final String message;
  final dynamic error;

  const SmsError(this.message, [this.error]);

  @override
  List<Object?> get props => [message, error];

  @override
  String toString() => 'SmsError(message: $message)';
}
