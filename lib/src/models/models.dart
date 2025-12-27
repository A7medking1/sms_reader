import 'package:equatable/equatable.dart';

/// Represents a single SMS message
class SmsMessage extends Equatable {
  final String sender;
  final String body;
  final int date;
  final int type; // 1=inbox, 2=sent, 3=draft

  const SmsMessage({
    required this.sender,
    required this.body,
    required this.date,
    required this.type,
  });

  bool get isSent => type == 2;
  bool get isReceived => type == 1;

  factory SmsMessage.fromMap(Map<String, dynamic> map) {
    return SmsMessage(
      sender: map['sender'] as String,
      body: map['body'] as String,
      date: map['date'] as int,
      type: map['type'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {'sender': sender, 'body': body, 'date': date, 'type': type};
  }

  SmsMessage copyWith({String? sender, String? body, int? date, int? type}) {
    return SmsMessage(
      sender: sender ?? this.sender,
      body: body ?? this.body,
      date: date ?? this.date,
      type: type ?? this.type,
    );
  }

  @override
  List<Object?> get props => [sender, body, date, type];

  @override
  String toString() => 'SmsMessage(sender: $sender, type: $type, date: $date)';
}

/// Represents a conversation with a contact
class SmsConversation extends Equatable {
  final String phoneNumber;
  final String lastMessage;
  final int lastDate;
  final int messageCount;

  const SmsConversation({
    required this.phoneNumber,
    required this.lastMessage,
    required this.lastDate,
    required this.messageCount,
  });

  factory SmsConversation.fromMap(Map<String, dynamic> map) {
    return SmsConversation(
      phoneNumber: map['phoneNumber'] as String,
      lastMessage: map['lastMessage'] as String,
      lastDate: map['lastDate'] as int,
      messageCount: map['messageCount'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'phoneNumber': phoneNumber,
      'lastMessage': lastMessage,
      'lastDate': lastDate,
      'messageCount': messageCount,
    };
  }

  SmsConversation copyWith({
    String? phoneNumber,
    String? lastMessage,
    int? lastDate,
    int? messageCount,
  }) {
    return SmsConversation(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      lastMessage: lastMessage ?? this.lastMessage,
      lastDate: lastDate ?? this.lastDate,
      messageCount: messageCount ?? this.messageCount,
    );
  }

  @override
  List<Object?> get props => [phoneNumber, lastMessage, lastDate, messageCount];

  @override
  String toString() =>
      'SmsConversation(phoneNumber: $phoneNumber, messageCount: $messageCount)';
}
