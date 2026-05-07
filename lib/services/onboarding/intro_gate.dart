import 'package:flutter/material.dart';
import 'package:flutter_chat_app/pages/intro_page.dart';
import 'package:flutter_chat_app/services/auth/auth_gate.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntroGate extends StatefulWidget {
  const IntroGate({super.key, this.next = const AuthGate()});

  static const introSeenKey = 'introSeen';

  final Widget next;

  @override
  State<IntroGate> createState() => _IntroGateState();
}

class _IntroGateState extends State<IntroGate> {
  bool? _hasSeenIntro;

  @override
  void initState() {
    super.initState();
    _loadIntroState();
  }

  Future<void> _loadIntroState() async {
    final preferences = await SharedPreferences.getInstance();

    if (!mounted) return;
    setState(() {
      _hasSeenIntro = preferences.getBool(IntroGate.introSeenKey) ?? false;
    });
  }

  Future<void> _finishIntro() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(IntroGate.introSeenKey, true);

    if (!mounted) return;
    setState(() {
      _hasSeenIntro = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasSeenIntro = _hasSeenIntro;

    if (hasSeenIntro == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (hasSeenIntro) {
      return widget.next;
    }

    return IntroPage(onFinished: _finishIntro);
  }
}
