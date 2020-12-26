import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'commons.dart';
import 'package:hive/hive.dart';
import 'package:dio/dio.dart';
import 'package:calculator_lite/CurrencyTab/Backend/currencyListItem.dart';

class CurrencyData {
  Dio dio = Dio();

  Future<String> getRemoteData(BuildContext context) async {
    try {
      DateTime now = DateTime.now();
      bool checkDateBox = await Hive.boxExists(CommonsData.updatedDateBox);

      if (checkDateBox) {
        final Box dateBox = await Hive.openBox(CommonsData.updatedDateBox);

        String lastChecked = dateBox.get(CommonsData.lastDateChecked);
        DateTime lastCheckedDate = DateTime.tryParse(lastChecked);

        if (lastCheckedDate != null &&
            lastCheckedDate.difference(now).inHours <= 3)
          return CommonsData.successToken;
      }

      Response _getBaseData =
          await dio.get(CommonsData.remoteUrl); // EUR by default.

      if (_getBaseData != null) {
        Map _baseJson = Map<String, dynamic>.from(_getBaseData.data);

        // Gets the newly updated date online.
        String updatedDate = _baseJson['date'];
        if (checkDateBox) {
          final Box dateBox = Hive.box(CommonsData.updatedDateBox);
          String dateStr = dateBox.get(CommonsData.updatedDateKey);
          DateTime dateTimeObj = DateTime.tryParse(dateStr);
          DateTime online = DateTime.tryParse(updatedDate);

          if (dateTimeObj != null &&
              dateTimeObj.year == online.year &&
              dateTimeObj.day == online.day &&
              dateTimeObj.month == online.month) {
            await dateBox.put(CommonsData.lastDateChecked, now.toString());
            return CommonsData.successToken;
          }
        }

        // get a list of all currencies.
        Map _ratesListBase = _baseJson['rates'];
        List<String> allCurrencies = _ratesListBase.keys.toList();

        // for each currency, store it's values in separate boxes. Each currency is used as base.

        for (String currentBase in allCurrencies) {
          String currentBaseUrl = '${CommonsData.remoteUrl}?from=$currentBase';
          await insertData(
              currency: currentBase,
              currentBaseUrl: currentBaseUrl,
              jsonData:
                  (currentBase.toLowerCase() == 'eur') ? _baseJson : null);
        }

        // get list of all currencies and store it with Name, FlagURL, Code.
        for (int count = 0; count < allCurrencies.length; count++)
          await writeCurrencyDetails(
              currencyCode: allCurrencies.elementAt(count),
              context: context,
              keyIndex: count);

        Box dateBox = await Hive.openBox(CommonsData.updatedDateBox);
        await dateBox.put(CommonsData.updatedDateKey, updatedDate);
        await dateBox.put(CommonsData.lastDateChecked, now.toString());

        return CommonsData.successToken;
      }

      // For response null.
      else
        return CommonsData.errorToken;
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
    String countryName;

    String localJson = await DefaultAssetBundle.of(context)
        .loadString('assets/countries.json');
    Map data = json.decode(localJson);
    List mapsList = data['countries']['country'];

    for (Map eachMap in mapsList) {
      if (eachMap['currencyCode'] == currencyCode) {
        countryName = eachMap['countryName'];

        String countryCode =
            eachMap['countryCode'].toString().trim().toLowerCase();
        flagURL = 'icons/flags/png/$countryCode.png';
        break;
      }
    }

    final currencyBox = await Hive.openBox(CommonsData.currencyListBox);
    final CurrencyListItem currencyListItem = CurrencyListItem(
      currencyCode: currencyCode,
      currencyName: countryName, // getting countryName for now.
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

      Response response = await dio.get(currentBaseUrl);

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
