import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money/money.dart';
import 'package:x_rate_monitor/data.dart';

class HistoryPage extends StatefulWidget {
  final Currency baseCurrency;

  const HistoryPage({Key key, this.baseCurrency}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState(baseCurrency);
}

class _HistoryPageState extends State<HistoryPage> {
  Currency _baseCurrency;
  Future<HistoricalRates> _historyFuture;

  DateTime _fromDate;
  DateTime _toDate;

  _HistoryPageState(this._baseCurrency);

  @override
  void initState() {
    super.initState();
    // by default we use date for last 90 days
    _fromDate = DateTime.now().subtract(Duration(days: 90));
    _toDate = DateTime.now();

    _historyFuture = getRatesHistory(
      baseCurrency: _baseCurrency,
      from: _fromDate,
      to: _toDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${_baseCurrency.name}"),
      ),
      body: FutureBuilder(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  snapshot.error.toString(),
                  textAlign: TextAlign.center,
                ),
                RaisedButton(
                  child: Text("Retry"),
                  onPressed: () {
                    // retry latest api call
                    setState(() {
                      _historyFuture = getRatesHistory(
                        baseCurrency: _baseCurrency,
                        from: _fromDate,
                        to: _toDate,
                      );
                    });
                  },
                )
              ],
            );
          }

          // loading state should check waiting as well to cover all cases
          if (!snapshot.hasData ||
              snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          // rates should be sorted by date ascending
          List<HistoryRatePoint> rates = snapshot.data.rates;
          rates.sort((a, b) => a.date.compareTo(b.date));

          final seriesList = _createListData(rates);
          return charts.TimeSeriesChart(seriesList,
              animate: false,
              defaultRenderer: charts.LineRendererConfig(includePoints: true));
        },
      ),
    );
  }

  static List<charts.Series<HistoryRatePoint, DateTime>> _createListData(
      List<HistoryRatePoint> data) {
    DateFormat pointDf = DateFormat("YY-MM-dd");
    return [
      charts.Series<HistoryRatePoint, DateTime>(
        id: 'Currency',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (HistoryRatePoint point, _) => point.date,
        measureFn: (HistoryRatePoint point, _) => point.rates.first.rate,
        data: data,
      )
    ];
  }
}
