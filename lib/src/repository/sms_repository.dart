import '../models/models.dart';
import '../services/sms_platform_service.dart';

/// Repository layer for SMS operations with business logic
class SmsRepository {
  final SmsPlatformService _platformService;

  SmsRepository(this._platformService);

  /// Fetch all conversations
  /// Returns a list of conversations sorted by most recent
  Future<List<SmsConversation>> fetchConversations() async {
    try {
      final conversations = await _platformService.getConversations();

      // Sort by most recent date
      conversations.sort((a, b) => b.lastDate.compareTo(a.lastDate));

      return conversations;
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch messages for a specific contact
  /// Returns a list of messages sorted by date (oldest first)
  Future<List<SmsMessage>> fetchMessagesByContact(String phoneNumber) async {
    try {
      final messages = await _platformService.getMessagesByContact(phoneNumber);

      // Sort by date (oldest first for chat display)
      messages.sort((a, b) => a.date.compareTo(b.date));

      return messages;
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch all SMS messages (legacy method)
  Future<List<SmsMessage>> fetchAllMessages() async {
    try {
      return await _platformService.getAllSMS();
    } catch (e) {
      rethrow;
    }
  }

  /// Search conversations by phone number or last message
  Future<List<SmsConversation>> searchConversations(String query) async {
    try {
      final conversations = await fetchConversations();

      if (query.isEmpty) return conversations;

      final lowerQuery = query.toLowerCase();
      return conversations.where((conv) {
        return conv.phoneNumber.toLowerCase().contains(lowerQuery) ||
            conv.lastMessage.toLowerCase().contains(lowerQuery);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Search messages in a conversation
  Future<List<SmsMessage>> searchMessages(
    String phoneNumber,
    String query,
  ) async {
    try {
      final messages = await fetchMessagesByContact(phoneNumber);

      if (query.isEmpty) return messages;

      final lowerQuery = query.toLowerCase();
      return messages.where((msg) {
        return msg.body.toLowerCase().contains(lowerQuery);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }
}
