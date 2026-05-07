import 'package:flutter/material.dart';
import 'package:flutter_chat_app/components/user_tile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('user tile shows username initial when no avatar is set', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UserTile(text: 'Maya', onTap: () {}),
        ),
      ),
    );

    expect(find.text('Maya'), findsOneWidget);
    expect(find.text('M'), findsOneWidget);
  });
}
