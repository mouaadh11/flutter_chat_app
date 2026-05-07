import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/pages/home_page.dart';
import 'package:flutter_chat_app/services/auth/login_or_register.dart';
import 'package:flutter_chat_app/services/chat/chat_notification.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  void _checkPendingChatOpen() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ChatNotification().tryOpenPendingChat();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _checkPendingChatOpen();
          return const HomePage();
        } else {
          return const LoginOrRegister();
        }
      },
    );
  }
}
