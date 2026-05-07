import 'package:flutter/material.dart';
import 'package:flutter_chat_app/services/onboarding/intro_gate.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Widget buildSubject({Widget next = const Text('Next screen')}) {
    return MaterialApp(home: IntroGate(next: next));
  }

  testWidgets('shows onboarding when intro has not been seen', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(buildSubject());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Chat App'), findsOneWidget);
    expect(find.text('Chat in the moment'), findsOneWidget);
    expect(find.text('Next screen'), findsNothing);
  });

  testWidgets('completion saves intro flag and reveals next screen', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(buildSubject());
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text('Skip'));
    await tester.pump(const Duration(milliseconds: 100));

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool(IntroGate.introSeenKey), isTrue);
    expect(find.text('Next screen'), findsOneWidget);
  });

  testWidgets('skips onboarding when intro has already been seen', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({IntroGate.introSeenKey: true});

    await tester.pumpWidget(buildSubject());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Next screen'), findsOneWidget);
    expect(find.text('Chat in the moment'), findsNothing);
  });
}
