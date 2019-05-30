import 'package:flutter_test/flutter_test.dart';
import 'package:x_rate_monitor/redux/actions.dart';
import 'package:x_rate_monitor/redux/reducers.dart';
import 'package:x_rate_monitor/redux/state.dart';

import '../data/mock_network_responses.dart';

void main() {
  final initialState = AppState.initial();

  test("set base amount action should update base amount", () {
    final newBaseAmount = 10.0;
    final newState = setBaseAmountReducer(initialState.ratesListState, ActionSetBaseAmount(newBaseAmount));

    expect(newState.baseAmount, equals(newBaseAmount));
  });

  group("set base amount actions calculates rates", () {
    final ratesData = mockRatesResponseWithBaseCurrency(mockBaseCurrency);
    final givenState = initialState.ratesListState.copyWith(
      baseCurrency: mockBaseCurrency,
      rates: ratesData.rates.map((rate) {
        return RateItemState(rate: rate, baseCurrency: mockBaseCurrency, targetAmount: 0.0);
      }).toList(),
    );

    ratesData.rates.forEach((rate) {
      test("rate for ${rate.currency} is correct", () {
        final newBaseAmount = 15.0;

        final reducedState = setBaseAmountReducer(givenState, ActionSetBaseAmount(newBaseAmount));

        final calculatedRateItem = reducedState.rates.firstWhere((rateItem) => rateItem.rate == rate);
        expect(calculatedRateItem.targetAmount, equals(newBaseAmount * rate.rate));
      });
    });
  });

  group("rates updated reducer tests", () {
    final response = mockRatesResponseWithBaseCurrency(mockBaseCurrency);

    test("changes rates list", () {
      final givenState = initialState.ratesListState;
      final newState = ratesUpdatedReducer(givenState, ActionRatesUpdated(response));

      expect(newState.rates.length, equals(response.rates.length));
    });

    test("updates available currencies lists", () {
      final givenState = initialState.ratesListState;
      final newState = ratesUpdatedReducer(givenState, ActionRatesUpdated(response));

      expect(newState.availableCurrencies, equals(response.rates.map((rate) => rate.currency).toList()));
    });

    test("doesn't change base amount", () {
      final givenState = initialState.ratesListState;
      final newState = ratesUpdatedReducer(givenState, ActionRatesUpdated(response));

      expect(newState.baseAmount, equals(givenState.baseAmount));
    });

    test("doesn't change base currency ", () {
      final givenState = initialState.ratesListState;
      final newState = ratesUpdatedReducer(givenState, ActionRatesUpdated(response));

      expect(newState.baseCurrency, equals(givenState.baseCurrency));
    });

    test("adds base currency rate to list", () {
      final responseNoBaseCurrency = mockRatesResponseWithoutBaseCurrency(mockBaseCurrency);
      final givenState = initialState.ratesListState;

      final newState = ratesUpdatedReducer(givenState, ActionRatesUpdated(responseNoBaseCurrency));

      expect(newState.availableCurrencies, contains(givenState.baseCurrency));
    });

    test("rates updated action ", () {
      final givenState = initialState.ratesListState;

      final newState = ratesUpdatedReducer(givenState, ActionRatesUpdated(response));

      expect(newState.availableCurrencies, contains(givenState.baseCurrency));
    });

    test("updates rates", () {
      final baseAmount = 10.0;
      final givenState = initialState.ratesListState.copyWith(baseAmount: baseAmount);
      final newState = ratesUpdatedReducer(givenState, ActionRatesUpdated(response));

      expect(
          newState.rates,
          equals(response.rates.map((rate) {
            // initial base amount is 1.0 so target amount should be just rate
            return RateItemState(rate: rate, baseCurrency: mockBaseCurrency, targetAmount: rate.rate * baseAmount);
          }).toList()));
    });
  });

  test("rates loading action sets loading state", () {
    final newState = ratesLoadingReducer(initialState.ratesListState, ActionRatesLoading());

    expect(newState.isLoading, isTrue); // loading flag should be set
    expect(newState.rates, equals([])); // no rates on loading - should be empty array
    expect(newState.error, isNull); // no error on loading
  });

  test("rates loading error reducer sets error state", () {
    final errorText = "some error";
    final newState = ratesLoadingErrorReducer(initialState.ratesListState, ActionRatesUpdateError(errorText));

    expect(newState.isLoading, isFalse);
    expect(newState.rates, equals([])); // no rates on error - should be empty array
    expect(newState.error, equals(errorText));
  });
}
