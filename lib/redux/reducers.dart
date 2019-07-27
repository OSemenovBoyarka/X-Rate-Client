import 'package:money/money.dart';
import 'package:redux/redux.dart';
import 'package:x_rate_monitor/redux/actions.dart';
import 'package:x_rate_monitor/redux/state.dart';

AppState mainReducer(AppState state, dynamic action) {
  return AppState(
    ratesListReducer(state.ratesListState, action),
    ratesHistoryReducer(state.ratesHistoryState, action),
  );
}

//region Rates list reducer
Reducer<RatesListState> ratesListReducer = combineReducers([
  TypedReducer<RatesListState, ActionSetBaseAmount>(setBaseAmountReducer),
  TypedReducer<RatesListState, ActionRatesUpdated>(ratesUpdatedReducer),
  TypedReducer<RatesListState, ActionRatesLoading>(ratesLoadingReducer),
  TypedReducer<RatesListState, ActionRatesUpdateError>(ratesLoadingErrorReducer),
]);

RatesListState setBaseAmountReducer(
  RatesListState state,
  ActionSetBaseAmount action,
) {
  return state.copyWith(
    rates: state.rates.map((prevRate) {
      // update rate code for
      return RateItemState(
          baseCurrency: state.baseCurrency, rate: prevRate.rate, targetAmount: action.baseAmount * prevRate.rate.rate);
    }).toList(),
    baseAmount: action.baseAmount,
  );
}

RatesListState ratesUpdatedReducer(RatesListState state, ActionRatesUpdated action) {
  // calculate available currencies based on network response
  List<Currency> availableCurrencies = action.ratesResponse.rates.map((rate) => rate.currency).toList();
  Currency newBaseCurrency = action.ratesResponse.baseCurrency;
  // for some currencies backend return base currency in the list and for some - doesn't
  if (!availableCurrencies.contains(newBaseCurrency)) {
    availableCurrencies.add(newBaseCurrency);
  }

  return state.copyWith(
    baseCurrency: newBaseCurrency,
    rates: action.ratesResponse.rates.map((rate) {
      return RateItemState(baseCurrency: state.baseCurrency, rate: rate, targetAmount: state.baseAmount * rate.rate);
    }).toList(),
    availableCurrencies: availableCurrencies,
    // no errors - data is loaded
    error: null,
    // data is loaded here
    isLoading: false,
  );
}

RatesListState ratesLoadingReducer(RatesListState state, ActionRatesLoading action) {
  // error should be cleared, loading is set, we keep prev rates for history
  return state.copyWith(
    error: null,
    isLoading: true,
  );
}

RatesListState ratesLoadingErrorReducer(RatesListState state, ActionRatesUpdateError action) {
  return state.copyWith(error: action.error.toString(), isLoading: false);
}

//endregion

RatesHistoryState ratesHistoryReducer(RatesHistoryState ratesHistoryState, action) {
  return ratesHistoryState;
}
