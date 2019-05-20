import 'dart:async';

import 'package:x_rate_monitor/bloc/history_events.dart';
import 'package:x_rate_monitor/model/models.dart';
import 'package:x_rate_monitor/model/repository.dart';

import 'bloc_provider.dart';

class HistoryBloc implements BaseBloc {
  final Repository _repository;
  final _stateController = StreamController<HistoricalRates>();
  final _eventController = StreamController<HistoryEvent>();

  Stream<HistoricalRates> get output => _stateController.stream;

  Sink<HistoryEvent> get input => _eventController.sink;

  HistoryBloc(this._repository) {
    _eventController.stream.listen((event) async {
      if (event is GetHistoryEvent) {
        try {
          // calling for backend and waiting for the result
          final result = await _repository.getRatesHistory(
            baseCurrency: event.baseCurrency,
            targetCurrencies: event.targetCurrencies,
            from: DateTime.now().subtract(Duration(days: event.historyDays)),
            to: DateTime.now(),
          );
          _stateController.sink.add(result);
        } catch (error) {
          _stateController.sink.addError(error);
        }
      }
    });
  }

  void dispose() {
    _stateController.close();
    _eventController.close();
  }
}
