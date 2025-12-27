import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reading_sms/src/core/get_it.dart';
import 'package:reading_sms/src/presentation/screen/sms_list_screen.dart';

import 'src/presentation/cubit/conversations_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupGetIt();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ConversationsCubit(repository: sl())..loadConversations(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          appBarTheme: AppBarTheme(
            elevation: 0,
          ),
        ),
        home: ConversationsScreen(),
      ),
    );
  }
}
