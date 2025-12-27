import 'package:flutter/services.dart';

import '../models/models.dart';

/// Low-level platform channel service for SMS operations
class SmsPlatformService {
  static const _channel = MethodChannel('com.example.myapp/sms');

  /// Get all conversations grouped by phone number
  Future<List<SmsConversation>> getConversations() async {
    try {
      final List<dynamic> result = await _channel.invokeMethod(
        'getConversations',
      );

      return result
          .map(
            (item) => SmsConversation.fromMap(Map<String, dynamic>.from(item)),
          )
          .toList();
    } on PlatformException catch (e) {
      throw SmsException('Failed to get conversations: ${e.message}', e.code);
    } catch (e) {
      throw SmsException('Unexpected error getting conversations: $e');
    }
  }

  /// Get all messages for a specific contact
  Future<List<SmsMessage>> getMessagesByContact(String phoneNumber) async {
    try {
      final List<dynamic> result = await _channel.invokeMethod(
        'getSMSByContact',
        {'phoneNumber': phoneNumber},
      );

      return result.map((item) => SmsMessage.fromMap(Map<String, dynamic>.from(item))).toList();
    } on PlatformException catch (e) {
      throw SmsException(
        'Failed to get messages for $phoneNumber: ${e.message}',
        e.code,
      );
    } catch (e) {
      throw SmsException('Unexpected error getting messages: $e');
    }
  }

  /// Get all SMS messages (legacy method)
  Future<List<SmsMessage>> getAllSMS() async {
    try {
      final List<dynamic> result = await _channel.invokeMethod('getSMS');

      return result.map((item) => SmsMessage.fromMap(Map<String, dynamic>.from(item))).toList();
    } on PlatformException catch (e) {
      throw SmsException('Failed to get all SMS: ${e.message}', e.code);
    } catch (e) {
      throw SmsException('Unexpected error getting all SMS: $e');
    }
  }
}

/// Custom exception for SMS operations
class SmsException implements Exception {
  final String message;
  final String? code;

  SmsException(this.message, [this.code]);

  @override
  String toString() => 'SmsException: $message${code != null ? ' (Code: $code)' : ''}';
}
