import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reading_sms/src/core/helper/helper_fun.dart';
import 'package:reading_sms/src/core/get_it.dart';
import 'package:reading_sms/src/presentation/cubit/chat_cubit.dart';
import 'package:reading_sms/src/presentation/cubit/sms_state.dart';
import 'package:reading_sms/src/presentation/widget/date_divider.dart';
import 'package:reading_sms/src/presentation/widget/message_bubble.dart';
import 'package:sticky_headers/sticky_headers.dart';

class ChatScreen extends StatefulWidget {
  final String phoneNumber;

  const ChatScreen({super.key, required this.phoneNumber});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ChatCubit(repository: sl())..loadMessages(widget.phoneNumber),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.phoneNumber),
          forceMaterialTransparency: true,
        ),
        body: BlocConsumer<ChatCubit, SmsState>(
          listener: (context, state) {
            if (state is MessagesLoaded) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollToBottom();
              });
            }
          },
          builder: (context, state) {
            final cubit = context.read<ChatCubit>();
            return ListView.builder(
              controller: _scrollController,
              reverse: true,
              itemCount: cubit.allMessages.length,
              itemBuilder: (context, index) {
                final message =
                    cubit.allMessages[cubit.allMessages.length - 1 - index];
                final isSent = message.type == 2;
                bool showDate = false;
                if (index == cubit.allMessages.length - 1) {
                  showDate = true;
                } else {
                  final nextMessage =
                      cubit.allMessages[cubit.allMessages.length - 2 - index];
                  showDate = !isSameDay(message.date, nextMessage.date);
                }
                return StickyHeader(
                  header: DateDivider(timestamp: message.date),
                  content: Column(
                    children: [
                      // if (showDate) ,
                      BuildMessageBubble(
                        isSent: isSent,
                        message: message,
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
