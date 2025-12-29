import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reading_sms/src/core/get_it.dart';
import 'package:reading_sms/src/core/helper/helper_fun.dart';
import 'package:reading_sms/src/presentation/cubit/conversations_cubit.dart';
import 'package:reading_sms/src/presentation/cubit/search_cubit.dart';
import 'package:reading_sms/src/presentation/cubit/sms_state.dart';
import 'package:reading_sms/src/presentation/screen/chat_screen.dart';
import 'package:reading_sms/src/presentation/screen/search_screen.dart';

class ConversationsScreen extends StatelessWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages'),
        forceMaterialTransparency: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      BlocProvider(
                        create: (context) => SearchCubit(repository: sl()),
                        child: SearchScreen(),
                      ),
                ),
              );
            },
            tooltip: 'Search Messages',
          ),
        ],
      ),
      body: BlocBuilder<ConversationsCubit, SmsState>(
        builder: (context, state) {
          final cubit = context.read<ConversationsCubit>();
          return state is SmsLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
            itemCount: cubit.allConversations.length,
            itemBuilder: (context, index) {
              final conversation = cubit.allConversations[index];
              return ListTile(
                leading: CircleAvatar(child: Icon(Icons.person)),
                title: Text(conversation.phoneNumber),
                subtitle: Text(
                  conversation.lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      formatDate(conversation.lastDate),
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    if (conversation.messageCount > 0)
                      Container(
                        margin: EdgeInsets.only(top: 4),
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${conversation.messageCount}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ChatScreen(
                            phoneNumber: conversation.phoneNumber,
                          ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
