// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:x_rate_monitor/redux/state.dart';
import 'package:x_rate_monitor/redux/store.dart';
import 'package:x_rate_monitor/ui/home.dart';

import 'data/mock_network_responses.dart';

void main() {
  testWidgets('RatesHistory widget happy path tests', (WidgetTester tester) async {
    // create fake store - we will test only happy path, so we don't need actual mocking, stub repository is ok for this
    final store = createStore(repository: StubRepository());
    await tester.pumpWidget(StoreProvider<AppState>(
      store: store,
      child: MaterialApp(
        title: 'X-Rate Monitor',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomePage(),
      ),
    ));

    // verify base currency code is displayed.
    expect(find.text(store.state.ratesListState.baseCurrency.code), findsOneWidget);

    // verify loading is not displayed - because we have stub repo - response should be instant
    expect(find.byWidgetPredicate((widget) => widget is ProgressIndicator), findsNothing);
  });
}
