import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money/money.dart';
import 'package:x_rate_monitor/data.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'X-Rate Monitor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomeStateInheritedWidget extends InheritedWidget {

  final double baseAmount;

  const HomeStateInheritedWidget({this.baseAmount, Widget child})
      : super(child: child);

  static HomeStateInheritedWidget of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(HomeStateInheritedWidget);
  }

  @override
  bool updateShouldNotify(HomeStateInheritedWidget oldWidget) {
    return baseAmount != oldWidget.baseAmount;
  }
}


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _baseAmountController;
  Future<CurrencyRate> _currencyRateFuture;
  double _currentBaseAmount;

  @override
  void initState() {
    _currencyRateFuture = getRates();
    _currentBaseAmount = 1.00;

    // TODO add currency formatter
    _baseAmountController =
        TextEditingController(text: _currentBaseAmount.toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return HomeStateInheritedWidget(
      baseAmount: _currentBaseAmount,
      child: Scaffold(
        appBar: AppBar(),
        body: FutureBuilder<CurrencyRate>(
            future: _currencyRateFuture,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                // TODO retry button
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              }

              // loading state should check waiting as well to cover all cases
              if (!snapshot.hasData ||
                  snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              var data = snapshot.data;

              List<Currency> availableCurrencies =
              data.rates.map((rate) => rate.currency).toList();
              // for some currencies backend return base currency in the list and for some - doesn't
              if (!availableCurrencies.contains(data.baseCurrency)) {
                availableCurrencies.add(data.baseCurrency);
              }

              return Column(
                children: <Widget>[
                  Card(
                    child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            DropdownButton<String>(
                              value: data.baseCurrency.code,
                              items: availableCurrencies
                                  .map((currency) =>
                                  DropdownMenuItem(
                                    value: currency.code,
                                    child: Text(currency.code),
                                  ))
                                  .toList(),
                              onChanged: (String value) {
                                // fetch new data from network
                                setState(() {
                                  _currencyRateFuture =
                                      getRates(baseCurrency: Currency(value));
                                });
                                print("Currency selected: $value");
                              },
                            ),
                            Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: TextField(
                                    controller: _baseAmountController,
                                    textAlign: TextAlign.end,
                                    keyboardType: TextInputType
                                        .numberWithOptions(
                                      signed: false,
                                      decimal: true,
                                    ),
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(16),
                                      WhitelistingTextInputFormatter(
                                          RegExp("^[0-9]+[\.,]?[0-9]*\$"))
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        if (value.isEmpty) {
                                          _currentBaseAmount = 0.0;
                                        } else {
                                          // TODO improve input formatting
                                          _currentBaseAmount = double.tryParse(
                                              value.replaceAll(",", "."));
                                        }
                                      });
                                    },
                                  ),
                                )),
                          ],
                        )),
                  ),
                  Expanded(
                    child: CurrencyRatesList(
                        currencyRate: data
                    ),
                  ),
                ],
              );
            }),
      ),
    );
  }
}

class CurrencyRatesList extends StatelessWidget {
  final CurrencyRate currencyRate;

  const CurrencyRatesList({Key key, this.currencyRate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: currencyRate.rates.length,
        itemBuilder: (context, itemIndex) {
          // get base amount from inherited widget
          final baseAmount = HomeStateInheritedWidget
              .of(context)
              .baseAmount;

          final item = currencyRate.rates[itemIndex];
          final convertedAmount = baseAmount * item.rate;
          final converted = Money.fromDouble(convertedAmount, item.currency);

          return ListTile(
            leading: Container(
              width: 64,
              height: 64,
              child: Image.asset(
                  'icons/currency/${item.currency.code.toLowerCase()}.png',
                  package: 'currency_icons'),
            ),
            title: Text("$converted"),
            subtitle: Text(
                "Rate: ${Money.fromDouble(
                    1.0, currencyRate.baseCurrency)} = ${Money.fromDouble(
                    item.rate, item.currency)}\n${item.currency.name}"),
          );
        });
  }
}
