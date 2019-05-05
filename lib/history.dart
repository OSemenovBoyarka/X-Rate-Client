import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:money/money.dart';
import 'package:x_rate_monitor/data.dart';

class HistoryPage extends StatefulWidget {
  final Currency baseCurrency;
  final Currency targetCurrency;

  const HistoryPage({Key key, this.baseCurrency, this.targetCurrency})
      : super(key: key);

  @override
  _HistoryPageState createState() {
    return _HistoryPageState(baseCurrency, targetCurrency);
  }
}

class _HistoryPageState extends State<HistoryPage> {
  // specifies initial number of points to display
  final _initialDataSize = 10;

  // days to pick data
  // TODO make days configurable from UI
  final _historyDays = 180;

  Currency _baseCurrency;
  Currency _targetCurrency;
  Future<HistoricalRates> _historyFuture;

  DateTime _fromDate;
  DateTime _toDate;

  _HistoryPageState(this._baseCurrency, this._targetCurrency);

  @override
  void initState() {
    super.initState();
    _fromDate = DateTime.now().subtract(Duration(days: _historyDays));
    _toDate = DateTime.now();

    _historyFuture = getRatesHistory(
      baseCurrency: _baseCurrency,
      targetCurrencies: [_targetCurrency],
      from: _fromDate,
      to: _toDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${_baseCurrency.name} to ${_targetCurrency.name}"),
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
                        targetCurrencies: [_targetCurrency],
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

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: AspectRatio(
              child: _buildHistoryChartChart(snapshot.data),
              aspectRatio: 1.0,
            ),
          );
        },
      ),
    );
  }

  charts.TimeSeriesChart _buildHistoryChartChart(
      HistoricalRates ratesResponse) {
    // rates should be sorted by date ascending
    List<HistoryRatePoint> rates = ratesResponse.rates;
    rates.sort((a, b) => a.date.compareTo(b.date));

    final dateStart = rates.length <= _initialDataSize
        ? rates.first.date
        : rates[rates.length - _initialDataSize].date;
    final dateEnd = rates.last.date;

    final seriesList = _createListData(rates);
    return charts.TimeSeriesChart(seriesList,
        animate: true,
        defaultRenderer: charts.LineRendererConfig(includePoints: true),
        primaryMeasureAxis: charts.NumericAxisSpec(
          tickProviderSpec: charts.BasicNumericTickProviderSpec(
            // zero bound is redundant, we want to see difference against time
            zeroBound: false,
            // rates are not whole
            dataIsInWholeNumbers: false,
            // we want to show non whole number, since some charts may have scale from 0 to 1
            desiredMinTickCount: 2,
            desiredMaxTickCount: 10,
          ),
        ),
// Following code sets initial viewport basically initial zoom level, but it doesn't work for now
// https://github.com/google/charts/issues/68

//        domainAxis: charts.DateTimeAxisSpec(
//          showAxisLine: true,
//          viewport: charts.DateTimeExtents(
//            start: dateEnd,
//            end: dateStart,
//          ),
//        ),
        behaviors: [
          charts.PanAndZoomBehavior(),
          // this behavior allows user
          charts.LinePointHighlighter(
              showHorizontalFollowLine:
              charts.LinePointHighlighterFollowLineType.nearest,
              showVerticalFollowLine:
              charts.LinePointHighlighterFollowLineType.nearest),
          charts.ChartTitle("${_baseCurrency.code} to ${_targetCurrency
              .code} rate for last $_historyDays days.",
              behaviorPosition: charts.BehaviorPosition.top,
              titleOutsideJustification: charts.OutsideJustification.start,
              innerPadding: 18),
        ]);
  }

  static List<charts.Series<HistoryRatePoint, DateTime>> _createListData(
      List<HistoryRatePoint> data) {
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
