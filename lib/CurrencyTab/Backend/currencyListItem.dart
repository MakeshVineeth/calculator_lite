import 'package:flutter/cupertino.dart';
import 'package:country_provider/country_provider.dart';

class CurrencyListItem {
  String currencyCode;
  String flagURL;
  String countryName;

  CurrencyListItem({@required this.currencyCode});

  void update() async {
    bool isChecked = false;

    List<Country> result =
        await CountryProvider.getCountryByCurrencyCode(currencyCode,
            filter: CountryFilter(
              isCurrency: true,
              isName: true,
              isAlpha2Code: true,
            ));

    for (int i = 0; i < result.length; i++) {
      List<Currency> currencies = result.elementAt(i).currencies;
      for (int i = 0; i < currencies.length; i++) {
        Currency current = currencies.elementAt(i);
        if (current.code == currencyCode) {
          String name = current.name;
          isChecked = true;
          break;
        }

        if (isChecked) break;
      }

      if (isChecked) break;
    }
  }
}
