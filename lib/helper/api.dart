import 'dart:async';
import 'dart:convert' show json, utf8;
import 'dart:io';


const apiCategory = {
  'name': 'Currency',
  'route': 'currency',
};

class Api {
  final HttpClient _httpClient = HttpClient();
  final _url = 'https://dev-api.qne.cloud/api/StockIns';

  Future<List> getUnits(String category) async {
    final uri = Uri.https(_url, '/$category');
    final jsonResponse = await _getJson(uri);
    if(jsonResponse == null || jsonResponse['units'] == null) {
      print('Error retrieving units.');
      return null;
    }
    return jsonResponse['units'];
  }

  Future<double> convert(String category, String amount, String fromUnit, String toUnit) async {
    final uri = Uri.https(_url, '/$category/convert',
    {'amount': amount, 'from': fromUnit, 'to': toUnit});

    final jsonResponse = await _getJson(uri);
    if (jsonResponse == null || jsonResponse['status'] == null) {
      print('Error Retrieving conversion.');
      return null;
    } else if (jsonResponse['status'] == 'error') {
      print(jsonResponse['message']);
      return null;
    }
    return jsonResponse['conversion'].toDouble();
  }

  Future<Map<String, dynamic>> _getJson (Uri uri) async {
    try {
      final httpRequest = await _httpClient.getUrl(uri);
      final httpResponse = await httpRequest.close();
      if(httpResponse.statusCode != HttpStatus.OK) {
        return null;
      }

      final responseBody = await httpResponse.transform(utf8.decoder).join();

      return json.decode(responseBody);
    } on Exception catch(e) {
      print('$e');
      return null;
    }
  } 
}



    // "id": "b7c15a9f-1397-4d83-9873-244b7cdfb203",
    // "stockInCode": "SIN1801/001",
    // "stockInDate": "2018-01-30",
    // "description": "Meng",
    // "referenceNo": null,
    // "title": null,
    // "totalAmount": 943.4,
    // "costCentre": null,
    // "project": "Serdang",
    // "stockLocation": "HQ"