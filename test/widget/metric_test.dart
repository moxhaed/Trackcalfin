import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trackcalfin/app/theme.dart';
import 'package:trackcalfin/features/common/widgets.dart';

void main() {
  // The Today card gives each metric ~74 dp on a 360 dp phone.
  testWidgets('Metric wraps a long label instead of overflowing', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(Brightness.light),
        home: const Scaffold(
          body: Center(
            child: SizedBox(
              width: 74,
              child: Metric(value: '0 g', label: 'protein / 140\u00a0g', dotColor: Colors.orange),
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.textContaining('protein / 140', findRichText: true), findsOneWidget);
  });
}
