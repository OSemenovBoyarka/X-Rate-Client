import 'package:redux/redux.dart';
import 'package:x_rate_monitor/redux/actions.dart';
import 'package:x_rate_monitor/redux/app_state.dart';
import 'package:x_rate_monitor/redux/middleware.dart';
import 'package:x_rate_monitor/repository.dart';

Store<AppState> createStore({Repository repository}) {
  repository = repository ?? ApiRepository();
  return Store(
    mainReducer,
    middleware: createMiddleware(repository),
    initialState: AppState.initial(),
  );
}

AppState mainReducer(AppState state, dynamic action) {
  return AppState(
    ratesListReducer(state.ratesListState, action),
    ratesHistoryReducer(state.ratesHistoryState, action),
  );
}

//region Rates list reducer
Reducer<RatesListState> ratesListReducer = combineReducers([
  TypedReducer<RatesListState, SetBaseAmountAction>(setBaseAmountReducer),
  TypedReducer<RatesListState, RatesUpdatedAction>(ratesUpdatedReducer),
  TypedReducer<RatesListState, RatesLoadingAction>(ratesLoadingReducer),
  TypedReducer<RatesListState, RatesUpdateErrorAction>(ratesLoadingErrorReducer),
]);

RatesListState ratesUpdatedReducer(RatesListState state,
    RatesUpdatedAction action,) {
  return state.copyWith(
    rates: action.ratesResponse.rates.map((rate) {
      return RateItemState(
          baseCurrency: state.baseCurrency,
          rate: rate,
          targetAmount: state.baseAmount * rate.rate);
    }),
    // no errors - data is loaded
    error: null,
    // data is loaded here
    isLoading: false,
  );
}

RatesListState setBaseAmountReducer(RatesListState state,
    SetBaseAmountAction action,) {
  return state.copyWith(
    rates: state.rates.map((prevRate) {
      // update rate code for
      return RateItemState(
          baseCurrency: state.baseCurrency,
          rate: prevRate.rate,
          targetAmount: action.baseAmount * prevRate.rate.rate);
    }),
    baseAmount: action.baseAmount,
  );
}

RatesListState ratesLoadingReducer(RatesListState state, RatesLoadingAction action) {
  // error should be cleared, loading is set, we keep prev rates for history
  return state.copyWith(
    error: null,
    isLoading: true,
  );
}

RatesListState ratesLoadingErrorReducer(RatesListState state, RatesUpdateErrorAction action) {
  return state.copyWith(
      error: action.error.toString(),
      isLoading: false
  );
}

//endregion



RatesHistoryState ratesHistoryReducer(
    RatesHistoryState ratesHistoryState, action) {
  return ratesHistoryState;
}
