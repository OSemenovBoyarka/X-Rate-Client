import 'package:money/money.dart';
import 'package:redux/redux.dart';
import 'package:x_rate_monitor/model/models.dart';
import 'package:x_rate_monitor/model/repository.dart';
import 'package:x_rate_monitor/redux/actions.dart';
import 'package:x_rate_monitor/redux/state.dart';

List<Middleware<AppState>> createMiddleware(Repository repository) =>
    [
      FetchRatesMiddleware(repository),
    ];

class FetchRatesMiddleware implements MiddlewareClass<AppState> {
  final Repository _repository;

  FetchRatesMiddleware(this._repository);

  @override
  void call(Store<AppState> store, action, NextDispatcher next) async {
    if (action is ActionSetBaseCurrency) {
      await _loadRates(next, action.baseCurrency);
    } else if (action is ActionRetryLoadRates) {
      await _loadRates(next, store.state.ratesListState.baseCurrency);
    } else {
      next(action);
    }
  }

  Future _loadRates(NextDispatcher next, Currency baseCurrency) async {
    // notify reducer that we are loading rates
    next(ActionRatesLoading());
    // perform actual load
    try {
      CurrencyRate result = await _repository.getRates(baseCurrency: baseCurrency);
      next(ActionRatesUpdated(result));
    } catch (e) {
      if (e is Exception) {
        e.toString();
      }
      next(ActionRatesUpdateError(e));
    }
  }
}
