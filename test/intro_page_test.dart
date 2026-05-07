import 'package:flutter/material.dart';
import 'package:flutter_chat_app/pages/intro_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders progress controls and advances between pages', (
    tester,
  ) async {
    var finished = false;

    await tester.pumpWidget(
      MaterialApp(
        home: IntroPage(
          onFinished: () {
            finished = true;
          },
        ),
      ),
    );

    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
    expect(find.text('Chat in the moment'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('Find your people'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('Get Started'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Get Started'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(finished, isTrue);
  });
}
