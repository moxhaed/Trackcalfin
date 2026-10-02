import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trackcalfin/app/floating_nav.dart';

void main() {
  testWidgets('the highlight travels with the indicator instead of jumping ahead of it', (tester) async {
    const tabs = [
      NavTab('Dashboard', Icons.insights_outlined, Icons.insights, '', ''),
      NavTab('Buy', Icons.shopping_basket_outlined, Icons.shopping_basket, '', ''),
      NavTab('Cook', Icons.soup_kitchen_outlined, Icons.soup_kitchen, '', ''),
      NavTab('Settings', Icons.tune_outlined, Icons.tune, '', ''),
    ];
    var index = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: StatefulBuilder(
            builder: (context, setState) => FloatingNav(
              tabs: tabs,
              index: index,
              onSelect: (i) => setState(() => index = i),
              onCapture: () {},
              captureLabel: 'Log something',
              popupOpen: ValueNotifier(false),
            ),
          ),
        ),
      ),
    );
    // How lit a tab is: its filled icon's opacity.
    double lit(IconData active) => tester.widget<Icon>(find.byIcon(active)).color!.a;
    expect((lit(Icons.insights), lit(Icons.soup_kitchen)), (1.0, 0.0));

    await tester.tap(find.text('Cook'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    expect(lit(Icons.soup_kitchen), lessThan(0.5), reason: 'not lit before the indicator gets there');
    expect(lit(Icons.insights), greaterThan(0), reason: 'the old tab dims as the indicator leaves');
    expect(lit(Icons.shopping_basket), greaterThan(0), reason: 'the tab it passes over lights up on the way');

    await tester.pumpAndSettle();
    expect((lit(Icons.insights), lit(Icons.shopping_basket), lit(Icons.soup_kitchen)), (0.0, 0.0, 1.0));
    expect(tester.getSemantics(find.bySemanticsLabel('Cook')), isSemantics(isSelected: true, isButton: true));
  });
}
