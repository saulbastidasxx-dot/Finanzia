import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finanzia/main.dart';

void main() {
  testWidgets('Finanzia app can be constructed', (tester) async {
    await tester.pumpWidget(const FinanziaApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
