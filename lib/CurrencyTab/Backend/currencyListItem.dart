import 'package:flutter/material.dart';
import 'package:country_provider/country_provider.dart';
import 'country_by_currency.dart';

class CurrencyListItem {
  final String currencyCode;
  String flagURL;
  String currencyName;

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
        // Check if currency code == given one.
        Currency current = currencies.elementAt(i);
        if (current.code == currencyCode) {
          currencyName = current.name;

          // Get full name using json and then get alpha2 code.
          for (int i = 0; i < countryJsonList.length; i++) {
            String iterateValue = countryJsonList.values
                .elementAt(i)
                .toString()
                .trim()
                .toLowerCase();
            String toCompareValue = currencyName.trim().toLowerCase();
            if (iterateValue == toCompareValue) {
              String countryName = countryJsonList.keys.elementAt(i);
              Country countryObj =
                  await CountryProvider.getCountryByFullname(countryName);
              flagURL =
                  'icons/flags/${countryObj.alpha2Code.toLowerCase().trim()}.png';
              print(flagURL);
              break;
            }
          }

          isChecked = true;
          break;
        }

        if (isChecked) break;
      }

      // breaking all loops as once we have all values, we don't have to iterate anymore.
      if (isChecked) break;
    }
  }
}
