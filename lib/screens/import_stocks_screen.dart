import 'dart:convert';
import 'package:flutter/material.dart';
import '../helper/file_manager.dart';
import '../helper/database_helper.dart';
import '../helper/api.dart';
import '../model/stock.dart';
import '../widgets/main_drawer.dart';
import '../styles/theme.dart' as Style;

class ImportStocksScreen extends StatefulWidget {
  static const routeName = '/update';
  @override
  ImportStocksScreenState createState() => ImportStocksScreenState();
}

class ImportStocksScreenState extends State<ImportStocksScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Stock> stockList;
  String counter = '0';
  final dbHelper = DatabaseHelper.instance;

  bool _isButtonClicked = false;
  String ip, port, dbCode;
  String urlStatus = 'not found';
  String _url = '';

  Future<Null> initProfileData() async {
    ip =  await FileManager.readProfile('ip_address');
    port =  await FileManager.readProfile('port_number');
    dbCode =  await FileManager.readProfile('company_name');
    if(ip != '' && port != '' && dbCode != '') {
      _url = 'http://$ip:$port/api/Stocks';
    } else {
      _url = 'https://dev-api.qne.cloud/api/Stocks';
      dbCode = 'OUCOP7';
    }
    setState((){
      urlStatus = _url;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initProfileData();
  }

  void _insert(String stockId, String stockCode, String stockName, String baseUOM) async {
    // row to insert
    Map<String, dynamic> row = {
      DatabaseHelper.columnStockId : stockId,
      DatabaseHelper.columnStockCode  : stockCode,
      DatabaseHelper.columnStockName  : stockName,
      DatabaseHelper.columnBaseUOM  : baseUOM
    };
    final id = await dbHelper.insert(row);
    print('inserted row id: $id');
  }

  void _update(String stockId, String stockCode, String stockName, String baseUOM) async {
    // row to update
    Map<String, dynamic> row = {
      DatabaseHelper.columnStockId : stockId,
      DatabaseHelper.columnStockCode  : stockCode,
      DatabaseHelper.columnStockName  : stockName,
      DatabaseHelper.columnBaseUOM  : baseUOM
    };
    final rowsAffected = await dbHelper.update(row);
    print('updated $rowsAffected row(s)');
  }

  Future<List> _fetchAndSaveStockData() async {


    final api = Api();
    var data = await api.getStocks(dbCode, _url);

    var receivedData = json.decode(data);
    stockList = receivedData.map<Stock>((json) => Stock.fromJson(json)).toList(); 

    int len = await FileManager.getStockLength();
    if(len == 0) {
      for(int i = 0; i < stockList.length; i++) {
        print('Saving Stock name: ${stockList[i].stockName}');
        _insert(stockList[i].id, stockList[i].stockCode, stockList[i].stockName, stockList[i].baseUOM);
      }
      FileManager.setStockLength(stockList.length);
    } else {
      // update the db by response.body
      for(int i = 0; i < stockList.length; i++) {
        print('Updating Stocks: ${stockList[i].stockName}');
        _update(stockList[i].id, stockList[i].stockCode, stockList[i].stockName, stockList[i].baseUOM);
      }
    }
    
    return stockList;
  }

  Future<List> _fetchExistingStock() async {
    print('query all rows:');
    List<Map> stockData = await dbHelper.queryAllRows();
    FileManager.setStockLength(stockData.length);
    return stockData;
  }

  Future<bool> _backButtonPressed() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Exit the Stock App?"),
        actions: <Widget>[
          FlatButton(
            child: Text('Yes'),
            onPressed: () => Navigator.pop(context, true),
          ),
          FlatButton(
            child: Text('No'),
            onPressed: () => Navigator.pop(context, false),
          ),
        ],
      )
    );
  }

  @override 
  Widget build(BuildContext context) {

    // read all the json file, it shows the number of downloaded items
    final status = Container(
      width: 200,
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
              Radius.circular(10),
          ),
          side: BorderSide(width: 1, color: Colors.black), 
        ),
      ),
      child: Center(
        child: FutureBuilder<List>(
          future: _isButtonClicked ? _fetchAndSaveStockData() : _fetchExistingStock(),
          builder: (context, snapshot) {
            switch(snapshot.connectionState) {
              case ConnectionState.none:
                return Text(
                  "0",
                  style: TextStyle(
                    fontSize: 50,
                    color: Colors.red
                  ),
                );
              case ConnectionState.active:
              case ConnectionState.waiting:
                return CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue));
              case ConnectionState.done:
                if(snapshot.hasError) {
                  return Text(
                    "Error:\n\n${snapshot.error}",
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  );
                }
                return Text(
                  '${snapshot.data.length}',
                  style: TextStyle(
                    fontSize: 50,
                  ),
                );     
            }
          },
        ),
      ),
    );

    final button = Padding(
      padding: EdgeInsets.all(10),
      child: MaterialButton(
        onPressed: () {
          // _fetchAndSaveStockData();
          setState(() {
            _isButtonClicked == false ? _isButtonClicked = true : _isButtonClicked = false;
          });
        },
        child: Text(
          'Import Stocks',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'QuickSand',
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        shape: StadiumBorder(),
        color: Colors.teal,
        splashColor: Colors.green[50],
        height: 55,
        minWidth: 200,
        elevation: 2,
      )
    ); 

    return WillPopScope(
      onWillPop: _backButtonPressed,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(
            'Import Stocks',
          ),
          backgroundColor: Style.Colors.mainAppBar,
        ),
        drawer: MainDrawer(),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                status,

                Center(
                  child: Text(
                    urlStatus,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                button,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
