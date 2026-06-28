import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ott_watch/main.dart';

void main() {
  testWidgets('App loads the splash experience', (WidgetTester tester) async {
    await tester.pumpWidget(const MovieGuideApp());
    await tester.pump(const Duration(milliseconds: 900));

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Image), findsAtLeastNWidgets(1));
  });
}
