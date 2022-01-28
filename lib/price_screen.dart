import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:bitcoin_ticker/coin_data.dart';
import 'package:flutter/cupertino.dart' show CupertinoPicker;
import 'dart:io' show Platform;
import "package:http/http.dart" as http;
import 'package:collection/collection.dart';

class PriceScreen extends StatefulWidget {
  @override
  _PriceScreenState createState() => _PriceScreenState();
}

class _PriceScreenState extends State<PriceScreen> {
  String selectedCurrency = 'USD';
  List<int> fetchedRates = List.filled(cryptoList.length, null);

  @override
  void initState() {
    super.initState();
    fetchRates();
  }

  Future<double> fetchRate(String baseCurrency, String quoteCurrency) async {
    http.Response response = await http.get(Uri.parse(
        'https://rest.coinapi.io/v1/exchangerate/$baseCurrency/$quoteCurrency?apikey=33546EA5-E5F4-4617-B268-75413527C18D'));

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to fetch rate. Status code: ${response.statusCode}');
    }

    final double rate = jsonDecode(response.body)['rate'];

    return rate;
  }

  void fetchRates() {
    setState(() {
      fetchedRates = List.filled(fetchedRates.length, null);
    });
    cryptoList.forEachIndexed((index, cryptoCurrency) {
      fetchRate(cryptoCurrency, selectedCurrency).then((rate) {
        setState(() {
          fetchedRates[index] = rate.toInt();
        });
      });
    });
  }

  void handleCurrencyChanged(dynamic currency) {
    setState(() {
      selectedCurrency =
          currency is String ? currency : currenciesList[currency];
    });
    fetchRates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🤑 Coin Ticker'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: cryptoList
                .mapIndexed(
                  (index, cryptoCurrency) => Padding(
                    padding: EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 0),
                    child: Card(
                      color: Colors.lightBlueAccent,
                      elevation: 5.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 28.0),
                        child: Text(
                          '1 $cryptoCurrency = ${fetchedRates[index] ?? '?'} $selectedCurrency',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          Container(
            height: 150.0,
            alignment: Alignment.center,
            padding: EdgeInsets.only(bottom: 30.0),
            color: Colors.lightBlue,
            child: Platform.isIOS
                ? CupertinoPicker(
                    backgroundColor: Colors.lightBlue,
                    itemExtent: 32.0,
                    onSelectedItemChanged: handleCurrencyChanged,
                    children: currenciesList
                        .map<Widget>((currency) => Text(currency))
                        .toList(),
                  )
                : DropdownButton<String>(
                    value: selectedCurrency,
                    items: currenciesList
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: handleCurrencyChanged,
                  ),
          ),
        ],
      ),
    );
  }
}
