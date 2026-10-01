import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orchard_beam/brand/look.dart';
import 'package:orchard_beam/flow/deck.dart';

void main() {
  testWidgets('home names Send Files to TV: Share', (tester) async {
    await tester.pumpWidget(MaterialApp(theme: appLook(), home: const Deck()));
    await tester.pump();
    expect(find.text('Send Files to TV: Share'), findsWidgets);
    expect(find.text('Send files'), findsOneWidget);
  });
}
