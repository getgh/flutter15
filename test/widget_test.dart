
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_firebase/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
  await tester.pumpWidget(const InventoryApp());

  expect(find.text('Inventory Home Page'), findsOneWidget);
  expect(find.byIcon(Icons.add), findsOneWidget);
  }, skip: true);
}
