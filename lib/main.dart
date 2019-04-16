import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _baseAmountController;
  CurrencyRate _currencyRate;

  @override
  void initState() {
    // TODO add async data init
    _currencyRate = getRates();

    _baseAmountController = TextEditingController(text: "1,00");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: <Widget>[
          Card(
            child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    DropdownButton<String>(
                      value: _currencyRate.baseCurrency,
                      // TODO more items
                      items: ["USD", "EUR"].map((currency) {
                        return DropdownMenuItem(
                          value: currency,
                          child: Text(currency),
                        );
                      }).toList(),
                      onChanged: (String value) {
                        setState(() {
                          // fetch new data from network
                          // TODO cancel previous downloads
                          _currencyRate = getRates(baseCurrency: value);
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
                        keyboardType: TextInputType.numberWithOptions(
                          signed: false,
                          decimal: true,
                        ),
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(16),
                          WhitelistingTextInputFormatter(
                              RegExp("^[0-9]+[\.,]?[0-9]*\$"))
                        ],
                      ),
                    )),
                  ],
                )),
          ),
          Expanded(
            child: ListView.builder(
                itemCount: _currencyRate.rates.length,
                itemBuilder: (context, itemIndex) {
                  final item = _currencyRate.rates[itemIndex];

                  // TODO add fancier layout and formatting
                  return Text("1.00 ${_currencyRate.baseCurrency} = ${item.rate} ${item.currency}");
                }),
          )
        ],
      ),
    );
  }
}
