import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;

class Api {
  final HttpClient _httpClient = HttpClient();

  // final _url = 'http://$ip:$port/api/Stocks';
  Future<String> getStocks(String dbCode, String _url) async {
    print("Accessing URL: $_url");
    http.Response response = await http.get(
      Uri.encodeFull(_url),
      headers: {
        "DbCode": dbCode,
        "Content-Type": "application/json"
      },
    );
    return response.body;
  }

  Future<Null> postStockIns(String dbCode, String body, String _url) async {
    // Prepare for the Post request (http)
    var response = await http.post(
      _url, 
      headers: {
        "Content-Type": "application/json",  
        "DbCode": dbCode
      },
      body: body);
    // includes datas into body
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
  }

  Future<Null> postMultipleStockIns(String dbCode, List<String> body, String _url) async {
    // Prepare for the Post request (http)   
    for(int i = 0; i < body.length; i++) {
      try {
        var response = await http.post(
          _url, 
          headers: {
            "Content-Type": "application/json",  
            "DbCode": dbCode
          },
          body: body[i]);
        print('Response body: ${response.body}');
      } finally {
        _httpClient.close();
      }
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