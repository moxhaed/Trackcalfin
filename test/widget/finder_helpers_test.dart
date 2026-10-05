// The guard tests' text finders read no-break spaces as spaces (the design binds a
// title's last two words and numbers to their units with U+00A0) without matching more
// widgets than `find.text` would.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_harness.dart';

void main() {
  testWidgets('text finders tolerate no-break spaces and keep exact counts', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              Text('Lighter bacon carbonara'),
              Text.rich(TextSpan(text: 'Uses your spinach · 51 g protein')),
              Text('IN THE FRIDGE'),
            ],
          ),
        ),
      ),
    );
    expect(find.text('Lighter bacon carbonara'), findsNothing, reason: 'why the helpers exist');
    expect(textExact('Lighter bacon carbonara'), findsOneWidget);
    expect(textExact('Lighter bacon'), findsNothing, reason: 'still exact');
    expect(textContains('51 g protein'), findsOneWidget);
    expect(textHas('51 g protein'), findsOneWidget);
    expect(textCI('In the fridge'), findsOneWidget);
    expect(textCI('lighter bacon carbonara'), findsOneWidget);
    expect(value('51 g'), findsOneWidget);
  });
}
