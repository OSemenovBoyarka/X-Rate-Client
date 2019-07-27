import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:money/money.dart';
import 'package:x_rate_monitor/redux/actions.dart';
import 'package:x_rate_monitor/redux/state.dart';
import 'package:x_rate_monitor/ui/history.dart';
import 'package:x_rate_monitor/util/text_formatting.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Foreign excange rates"),
      ),
      body: StoreConnector<AppState, RatesListState>(
        // TODO add viewmodel only with loading and has errors to implement distinct caching
        converter: (store) => store.state.ratesListState,
        builder: (context, state) {
          if (state.error != null) {
            return _buildRatesLoadingError(state.error);
          }

          // loading state
          if (state.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          // data loaded all is ok
          return Column(
            children: <Widget>[
              buildHeaderCard(state),
              Expanded(
                child: CurrencyRatesList(rates: state.rates),
              ),
            ],
          );
        },
      ),
    );
  }

  Column _buildRatesLoadingError(String error) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          error,
          textAlign: TextAlign.center,
        ),
        StoreBuilder<AppState>(
          builder: (context, store) =>
              RaisedButton(
                child: Text("Retry"),
                onPressed: () {
                  // retry by repeating setting the model
                  store.dispatch(ActionRetryLoadRates());
                },
              ),
        )
      ],
    );
  }

  Widget buildHeaderCard(RatesListState state) {
    return Card(
      child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              StoreBuilder<AppState>(
                builder: (context, store) =>
                    DropdownButton<String>(
                      value: state.baseCurrency.code,
                      items: state.availableCurrencies
                          .map((currency) =>
                          DropdownMenuItem(
                            value: currency.code,
                            child: Text(currency.code),
                          ))
                          .toList(),
                      onChanged: (String value) {
                        // fetch new data from network
                        store.dispatch(ActionSetBaseCurrency(Currency(value)));
                      },
                    ),
              ),
              Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: buildBaseAmountInput(state.baseAmount, state.baseCurrency),
                  )),
            ],
          )),
    );
  }

  Widget buildBaseAmountInput(double baseAmount, Currency baseCurrency) {
    return StoreBuilder<AppState>(
      builder: (context, store) {
        // initial text should be formatted same as in CurrencyAmountTextInputFormatter
        // to avoid endless loop
        var text = Money.fromDouble(baseAmount, baseCurrency).amountAsString;
        return TextField(
            controller: TextEditingController(text: text),
            enableInteractiveSelection: false, // for simplicity user should not be able to change selection
            textAlign: TextAlign.end,
            keyboardType: TextInputType.numberWithOptions(
              signed: false,
              decimal: true,
            ),
            inputFormatters: [
              LengthLimitingTextInputFormatter(16),
              CurrencyAmountTextInputFormatter(currency: baseCurrency)
            ],
            onChanged: (value) {
              baseAmount = value.isEmpty ? 0.0 : double.tryParse(value.replaceAll(",", "."));
              // dispatch new base amount to store
              store.dispatch(ActionSetBaseAmount(baseAmount));
            },
          );
      },
    );
  }
}

class HomeInputHeaderCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class CurrencyRatesList extends StatelessWidget {
  final List<RateItemState> rates;

  const CurrencyRatesList({Key key, this.rates}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: rates.length,
        itemBuilder: (context, itemIndex) {
          final item = rates[itemIndex];
          final currency = item.rate.currency;
          final converted = Money.fromDouble(item.targetAmount, currency);

          return ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        HistoryPage(
                          baseCurrency: item.baseCurrency,
                          targetCurrency: currency,
                        )),
              );
            },
            leading: Hero(
              tag: currency,
              child: Container(
                width: 64,
                height: 64,
                child: Image.asset('icons/currency/${currency.code.toLowerCase()}.png', package: 'currency_icons'),
              ),
            ),
            title: Text("$converted"),
            subtitle: Text(
                "Rate: ${Money.fromDouble(1.0, item.baseCurrency)} = ${Money.fromDouble(
                    item.rate.rate, currency)}\n${currency.name}"),
          );
        });
  }
}
