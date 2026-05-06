import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:attend_pro/main.dart';

void main() {
  testWidgets('AttendPro smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: AttendProApp()));
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
