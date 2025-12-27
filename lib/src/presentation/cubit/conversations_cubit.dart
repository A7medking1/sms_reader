import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reading_sms/src/models/models.dart';
import 'package:reading_sms/src/presentation/cubit/sms_state.dart';
import 'package:reading_sms/src/repository/sms_repository.dart';


class ConversationsCubit extends Cubit<SmsState> {
  final SmsRepository _repository;

  ConversationsCubit({required SmsRepository repository})
    : _repository = repository,
      super(
        const SmsInitial(),
      );

  List<SmsConversation> allConversations = [];

  Future<void> loadConversations() async {
    emit(const SmsLoading());

    try {
      final conversations = await _repository.fetchConversations();
      allConversations = conversations;
      emit(ConversationsLoaded());
    } catch (e) {
      emit(SmsError('Failed to load conversations', e));
    }
  }

  Future<void> refresh() async {
    await loadConversations();
  }

  Future<void> searchConversations(String query) async {
    emit(const SmsLoading());

    try {
      final conversations = await _repository.searchConversations(query);
      allConversations = conversations;
      emit(ConversationsLoaded());
    } catch (e) {
      emit(SmsError('Failed to search conversations', e));
    }
  }
}
