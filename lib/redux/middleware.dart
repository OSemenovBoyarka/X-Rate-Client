import 'package:redux/redux.dart';
import 'package:x_rate_monitor/models/models.dart';
import 'package:x_rate_monitor/redux/actions.dart';
import 'package:x_rate_monitor/redux/app_state.dart';
import 'package:x_rate_monitor/repository.dart';

List<Middleware<AppState>> createMiddleware(Repository repository) =>
    [
      FetchRatesMiddleware(repository),
    ];

class FetchRatesMiddleware implements MiddlewareClass<AppState> {
  final Repository _repository;

  FetchRatesMiddleware(this._repository);

  @override
  void call(Store<AppState> store, action, NextDispatcher next) async {
    if (action is SetBaseCurrencyAction) {
      // notify reducer that we are loading rates
      next(RatesLoadingAction);
      // perform actual load
      try {
        CurrencyRate result = await _repository.getRates(baseCurrency: action.baseCurrency);
        next(RatesUpdatedAction(result));
      } catch (e) {
        next(RatesUpdateErrorAction(e));
      }
    } else {
      next(action);
    }
  }
}
