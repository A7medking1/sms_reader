import 'package:flutter/material.dart';
import 'package:reading_sms/src/models/models.dart';

class BuildMessageBubble extends StatelessWidget {
  const BuildMessageBubble({
    super.key,
    required this.isSent,
    required this.message,
  });

  final bool isSent;
  final SmsMessage message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSent ? Colors.blue[100] : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message.body, style: TextStyle(fontSize: 16)),
            SizedBox(height: 4),
            Text(
              _formatTime(message.date),
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

