import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reading_sms/src/models/models.dart';
import 'package:reading_sms/src/presentation/cubit/sms_state.dart';
import 'package:reading_sms/src/repository/sms_repository.dart';


class ChatCubit extends Cubit<SmsState> {
  final SmsRepository _repository;
  String? _currentPhoneNumber;

  ChatCubit({required SmsRepository repository}) : _repository = repository, super(const SmsInitial());

  List<SmsMessage> allMessages = [];

  Future<void> loadMessages(String phoneNumber) async {
    _currentPhoneNumber = phoneNumber;
    emit(const SmsLoading());

    try {
      final messages = await _repository.fetchMessagesByContact(phoneNumber);
      allMessages = messages;
      emit(MessagesLoaded());
    } catch (e) {
      emit(SmsError('Failed to load messages for $phoneNumber', e));
    }
  }

  Future<void> refresh() async {
    if (_currentPhoneNumber != null) {
      await loadMessages(_currentPhoneNumber!);
    }
  }

  Future<void> searchMessages(String query) async {
    if (_currentPhoneNumber == null) return;

    emit(const SmsLoading());

    try {
      final messages = await _repository.searchMessages(
        _currentPhoneNumber!,
        query,
      );
      allMessages = messages;

      emit(MessagesLoaded());
    } catch (e) {
      emit(SmsError('Failed to search messages', e));
    }
  }
}
