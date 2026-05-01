import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/services/auth/auth_gate.dart';
import 'package:flutter_chat_app/firebase_options.dart';
import 'package:flutter_chat_app/themes/mode_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    ChangeNotifierProvider(create: (context) => ModeProvider(), child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  void requestPermission() async {
    final FlutterLocalNotificationsPlugin notificationsPlugin =
        FlutterLocalNotificationsPlugin();
    final androidPlugin = notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.requestNotificationsPermission();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    requestPermission();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ModeProvider>(context).currentMode,
      home: AuthGate(),
    );
  }
}
