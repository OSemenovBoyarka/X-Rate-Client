import 'package:redux/redux.dart';
import 'package:x_rate_monitor/redux/actions.dart';
import 'package:x_rate_monitor/redux/app_state.dart';

Store<AppState> createStore() {
  return Store(
    mainReducer,
    initialState: AppState.initial(),
  );
}

AppState mainReducer(AppState state, dynamic action) {
  return AppState(ratesListReducer(state.ratesListState, action),
      ratesHistoryReducer(state.ratesHistoryState, action));
}

RatesListState ratesListReducer(RatesListState state, action) {
  if (action is SetBaseCurrencyAction) {
    return RatesListState(
      baseCurrency: action.baseCurrency,
      rates: state.rates,
      error: null,
      isLoading: true,
      // after set new currency - we should display data loading
      baseAmount: state.baseAmount,
    );
  }
  return state;
}

RatesHistoryState ratesHistoryReducer(
    RatesHistoryState ratesHistoryState, action) {
  return ratesHistoryState;
}
