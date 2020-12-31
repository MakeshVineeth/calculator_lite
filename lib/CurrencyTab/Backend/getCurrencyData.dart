import 'dart:convert';
import 'package:calculator_lite/Backend/helperFunctions.dart';
import 'package:flutter/cupertino.dart';
import 'commons.dart';
import 'package:hive/hive.dart';
import 'package:dio/dio.dart';
import 'package:calculator_lite/CurrencyTab/Backend/currencyListItem.dart';

class CurrencyData {
  HelperFunctions helperFunctions = HelperFunctions();

  Future<String> getRemoteData(
      {@required BuildContext context, @required Map baseJson}) async {
    try {
      // get a list of all currencies.
      Map _ratesListBase = baseJson['rates'];
      List<String> allCurrencies = _ratesListBase.keys.toList();

      // for each currency, store it's values in separate boxes. Each currency is used as base.

      for (String currentBase in allCurrencies) {
        String currentBaseUrl = '${CommonsData.remoteUrl}?from=$currentBase';
        await insertData(
            currency: currentBase,
            currentBaseUrl: currentBaseUrl,
            jsonData: (currentBase.toLowerCase() == 'eur') ? baseJson : null);
      }

      // get list of all currencies and store it with Name, FlagURL, Code.
      for (int count = 0; count < allCurrencies.length; count++)
        await writeCurrencyDetails(
            currencyCode: allCurrencies.elementAt(count),
            context: context,
            keyIndex: count);

      return CommonsData.successToken;
    } on DioError catch (e) {
      print('Exception: ' + e.toString());
      return e.toString();
    } catch (e) {
      print('Exception getRemoteData: ' + e.toString());
      return e.toString();
    }
  }

  Future<void> writeCurrencyDetails(
      {@required String currencyCode,
      @required BuildContext context,
      @required int keyIndex}) async {
    String flagURL;
    String currencyName;

    String countryJson = await DefaultAssetBundle.of(context)
        .loadString('assets/countries.json');
    Map data = json.decode(countryJson);
    List mapsList = data['countries']['country'];

    String currencyJson = await DefaultAssetBundle.of(context)
        .loadString('assets/currencies.json');
    Map currencyMap = json.decode(currencyJson);

    for (Map eachMap in mapsList) {
      if (eachMap['currencyCode'] == currencyCode) {
        currencyName = currencyMap[currencyCode]['name'];
        currencyName = helperFunctions.normalizeName(currencyName);

        String countryCode =
            eachMap['countryCode'].toString().trim().toLowerCase();
        flagURL = 'icons/flags/png/$countryCode.png';
        break;
      }
    }

    final currencyBox = await Hive.openBox(CommonsData.currencyListBox);
    final CurrencyListItem currencyListItem = CurrencyListItem(
      currencyCode: currencyCode,
      currencyName: currencyName,
      flagURL: flagURL,
    );

    await currencyBox.put(keyIndex, currencyListItem);
  }

  Future<String> insertData(
      {@required String currency,
      @required String currentBaseUrl,
      Map jsonData}) async {
    final box = await Hive.openBox(currency.toLowerCase());
    try {
      // if jsonData not null, meaning this currency data already exists, no need to get response again.
      if (jsonData != null) {
        Map rates = jsonData['rates'] as Map;
        await box.putAll(rates);
        return CommonsData.successToken;
      }

      Response response = await CommonsData.getResponse(currentBaseUrl);

      if (response != null) {
        Map data = Map<String, dynamic>.from(response.data);
        Map rates = data['rates'] as Map;

        await box.putAll(rates);
        return CommonsData.successToken;
      } else
        return CommonsData.errorToken;
    } on DioError catch (e) {
      print('Dio Error: ' + e.toString());
      return CommonsData.errorToken;
    } catch (e) {
      print('Exception: ' + e.toString());
      return CommonsData.errorToken;
    }
  }
}
