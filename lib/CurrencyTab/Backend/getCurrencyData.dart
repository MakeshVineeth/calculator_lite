import 'dart:convert';
import 'package:http/http.dart' as http;
import 'commons.dart';
import 'package:hive/hive.dart';
import 'package:calculator_lite/CurrencyTab/Backend/currencyListItem.dart';
import 'package:country_provider/country_provider.dart';
import 'country_by_currency.dart';

class CurrencyData {
  Future<http.Response> getResponse(String url) async {
    try {
      String httpTag = 'https://';
      return await http.get('$httpTag$url');
    } catch (e) {
      return null;
    }
  }

  Future<void> getRemoteData() async {
    try {
      http.Response _getBaseData =
          await getResponse(CommonsData.remoteUrl); // EUR by default.

      if (_getBaseData != null) {
        Map _baseJson = jsonDecode(_getBaseData.body);

        String updatedDate = _baseJson['date'];
        Box lastUpdate = await Hive.openBox(CommonsData.updatedDateBox);
        lastUpdate.put(CommonsData.updatedDateKey, updatedDate);

        Map _ratesListBase = _baseJson['rates'];
        List<String> allCurrencies = _ratesListBase.keys.toList();

        allCurrencies.forEach((currentBase) async {
          String currentBaseUrl = '${CommonsData.remoteUrl}?from=$currentBase';
          await insertData(currentBase, currentBaseUrl);
        });

        await getCurrenciesList(allCurrencies);
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  Future<void> getCurrenciesList(List<String> allCurrencies) async {
    await Hive.openBox(CommonsData.currencyListBox);
    allCurrencies.forEach((currencyCode) async {
      await writeCurrencyDetails(currencyCode);
    });
  }

  Future<void> writeCurrencyDetails(String currencyCode) async {
    String flagURL;
    String currencyName;
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

    final currencyBox = Hive.box(CommonsData.currencyListBox);
    final CurrencyListItem currencyListItem = CurrencyListItem(
      currencyCode: currencyCode,
      currencyName: currencyName,
      flagURL: flagURL,
    );

    currencyBox.add(currencyListItem);
  }

  Future<void> insertData(String currency, String currentBaseUrl) async {
    try {
      http.Response response = await getResponse(currentBaseUrl);
      if (response != null) {
        Map data = jsonDecode(response.body);
        Map rates = data['rates'] as Map;
        if (rates.length > 0) {
          final box = await Hive.openBox(currency);
          rates.forEach((key, value) => box.put(key, double.tryParse(value)));
        }
      }
    } catch (e) {}
  }
}
