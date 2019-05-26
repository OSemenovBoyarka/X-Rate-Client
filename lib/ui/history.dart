import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:money/money.dart';
import 'package:x_rate_monitor/bloc/bloc_provider.dart';
import 'package:x_rate_monitor/bloc/history_bloc.dart';
import 'package:x_rate_monitor/bloc/history_events.dart';
import 'package:x_rate_monitor/model/models.dart';
import 'package:x_rate_monitor/model/repository.dart';

class HistoryPage extends StatelessWidget {
  final Currency baseCurrency;
  final Currency targetCurrency;

  // days to pick data
  final _historyDays = 180;

  // specifies initial number of points to display
//  final _initialDataSize = 10; see comments below

  const HistoryPage({
    Key key,
    @required this.baseCurrency,
    @required this.targetCurrency,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HistoryBloc>(
        bloc: HistoryBloc(ApiRepository()),
        // builder required to be able search ancestors
        child: Builder(builder: (context) => _buildPage(context)));
  }

  Widget _buildPage(BuildContext context) {
    // load initial data
    BlocProvider
        .of<HistoryBloc>(context)
        .input
        .add(GetHistoryEvent(baseCurrency, [targetCurrency], _historyDays));

    return Scaffold(
      appBar: AppBar(
        title: Text("${baseCurrency.name} to ${targetCurrency.name}"),
      ),
      body: Column(
        children: <Widget>[
          Row(children: <Widget>[
            Hero(
              tag: this.targetCurrency,
              child: Container(
                width: 64,
                height: 64,
                child: Image.asset('icons/currency/${this.targetCurrency.code.toLowerCase()}.png',
                    package: 'currency_icons'),
              ),
            ),
            Text("${baseCurrency.code} to ${targetCurrency.code} rate for last $_historyDays days."),
          ]),
          StreamBuilder(
            stream: BlocProvider
                .of<HistoryBloc>(context)
                .output,
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
                        BlocProvider
                            .of<HistoryBloc>(context)
                            .input
                            .add(GetHistoryEvent(baseCurrency, [targetCurrency], _historyDays));
                      },
                    )
                  ],
                );
              }

              // loading state should check waiting as well to cover all cases
              if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting) {
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
        ],
      ),
    );
  }

  charts.TimeSeriesChart _buildHistoryChartChart(HistoricalRates ratesResponse) {
    // rates should be sorted by date ascending
    List<HistoryRatePoint> rates = ratesResponse.rates;
    rates.sort((a, b) => a.date.compareTo(b.date));

    // See comment below
//    final dateStart = rates.length <= _initialDataSize
//        ? rates.first.date
//        : rates[rates.length - _initialDataSize].date;
//    final dateEnd = rates.last.date;

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
          // this behavior allows user to highlight poits on the graph
          charts.LinePointHighlighter(
              showHorizontalFollowLine: charts.LinePointHighlighterFollowLineType.nearest,
              showVerticalFollowLine: charts.LinePointHighlighterFollowLineType.nearest),
        ]);
  }

  static List<charts.Series<HistoryRatePoint, DateTime>> _createListData(List<HistoryRatePoint> data) {
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
