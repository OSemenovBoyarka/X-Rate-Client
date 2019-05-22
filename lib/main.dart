import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:x_rate_monitor/redux/actions.dart';
import 'package:x_rate_monitor/redux/state.dart';
import 'package:x_rate_monitor/redux/store.dart';
import 'package:x_rate_monitor/ui/home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final Store<AppState> store = createStore();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // load initial data
    // TODO think of more elegant way
    store.dispatch(ActionSetBaseCurrency(null));

    return StoreProvider<AppState>(
      store: store,
      child: MaterialApp(
        title: 'X-Rate Monitor',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomePage(),
      ),
    );
  }
}
