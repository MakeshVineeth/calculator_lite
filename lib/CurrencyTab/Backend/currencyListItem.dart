import 'package:flutter/cupertino.dart';
import 'package:country_provider/country_provider.dart';

class CurrencyListItem {
  String currencyCode;
  String flagURL;
  String countryName;

  CurrencyListItem({@required this.currencyCode});

  void update() async {
    List<Country> result =
        await CountryProvider.getCountryByCurrencyCode(currencyCode);
    print('Result $result');
  }
}
