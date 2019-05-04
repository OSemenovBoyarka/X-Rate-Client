import 'package:flutter/material.dart';
import 'package:money/money.dart';

class HistoryPage extends StatefulWidget {
  final Currency baseCurrency;

  const HistoryPage({Key key, this.baseCurrency}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState(baseCurrency);
}

class _HistoryPageState extends State<HistoryPage> {
  Currency _baseCurrency;

  _HistoryPageState(this._baseCurrency);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${_baseCurrency.name}"),
      ),
    );
  }
}
