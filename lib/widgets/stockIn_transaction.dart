import 'dart:convert';

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../model/stockIn.dart';
import '../model/uoms.dart';
import '../helper/api.dart';
import '../screens/home_screen.dart';
import '../helper/database_helper.dart';
import '../helper/file_manager.dart';

class StockInTransaction extends StatefulWidget {
  @override
  _StockInTransactionState createState() => _StockInTransactionState();
}

class _StockInTransactionState extends State<StockInTransaction> {
  final dbHelper = DatabaseHelper.instance;
  bool _isButtonDisabled = true;

  List<TextEditingController> _stockInputControllers = new List();
  List<TextEditingController> _lvl1InputControllers = new List();
  List<TextEditingController> _lvl2InputControllers = new List();

  List<FocusNode> _stockInputNodes = new List();
  List<FocusNode> _lvl1InputNodes = new List();
  List<FocusNode> _lvl2InputNodes = new List();

  String trxNumber = '';
  String stockId = '';

  List<String> _lvl1uomList = [];
  List<String> _lvl2uomList = [];
  List<String> _stockNames = [];
  List<Uoms> uomList = [];
  List<Details> detail = [];
  // Dropdown menu variables
  List<String> _descriptions = [];
  List<String> _descripts = [];
  String dropdownValue = '';
  String buffer = '';
  String trueVal = '';

  bool postClicked = false;
  List<bool> _isUOMEnabledList = [false];
  // URL preparation function initialization
  String ip, port, dbCode;
  String _url = '';


  Future<Null> initServerUrl() async {
    ip =  await FileManager.readProfile('ip_address');
    port =  await FileManager.readProfile('port_number');
    dbCode =  await FileManager.readProfile('company_name');
    if(ip != '' && port != '' && dbCode != '') {
      _url = 'http://$ip:$port/api/';
    } else {
      _url = 'https://dev-api.qne.cloud/api/';
      dbCode = 'OUCOP7';
    }
  }


  Future<Null> _searchStockCode(int index, String stockCode) async {
    bool isEmpty = false;
    List<Map> stockData = await dbHelper.queryAllRows();
    final api = Api();

    stockData.forEach((row) async {
      if(row["stockCode"] == stockCode) {
        print('ID: ${row["id"]}');
        _stockNames[index] = (row["stockName"]);
        // _lvl1_baseUOM[index] = (row["baseUOM"]);

        isEmpty = isEmpty || true;
        print('I got this :)');
        // _lvl1InputControllers[index].text = row["baseUOM"];

        // this will build baseUOM lvl1, lvl2 widgets
        stockId = row["stockId"];
        //Fetching Unit of Measurements for the Stock.
        var data = await api.getStocks(dbCode, '${_url}Stocks/$stockId/UOMS');
        var receivedData = json.decode(data);
        uomList = receivedData.map<Uoms>((json) => Uoms.fromJson(json)).toList();
        print("Length UOMs: ${uomList.length}");
        setState(() {
          if(uomList.length > 1) {
            if(uomList[0].isBaseUOM == true) {
              _lvl1uomList[index] = uomList[0].uomCode;
              _lvl2uomList[index] = uomList[1].uomCode;
            } else if(uomList[1].isBaseUOM == true){
              _lvl1uomList[index] = uomList[1].uomCode;
              _lvl2uomList[index] = uomList[0].uomCode;
            }
            _isUOMEnabledList[index] = true;
            // enable both lvl1 and lvl2 input fields
          } else {
            _lvl1uomList[index] = uomList[0].uomCode;
            _lvl2uomList[index] = '';
            // disable lvl2 input field
            _isUOMEnabledList[index] = false;
          }
        });
      } else {
        isEmpty = isEmpty || false;
      }
    });

    setState(() {
      _isButtonDisabled = !isEmpty;
    });
  }


  Future<Null> _stockInEventListener(int index, TextEditingController _controller) async {
    int length = _stockInputControllers.length;

    print('Length of the controllers: $length, index: $index');

    buffer = _controller.text;

    if(buffer.endsWith(r'$')) {
      buffer = buffer.substring(0, buffer.length - 1);
      trueVal = buffer;


      await Future.delayed(const Duration(milliseconds: 1000), (){
        _stockInputControllers[index].text = trueVal;
      }).then((value){
        _searchStockCode(index, trueVal);
        Future.delayed(const Duration(milliseconds: 500), (){
          // _stockInputController.clear();
          _stockInputNodes[index].unfocus();
          FocusScope.of(context).requestFocus(new FocusNode());
        });
      });
    }

  }

  Future<Null> _focusNode(BuildContext context, FocusNode node) async {
    FocusScope.of(context).requestFocus(node);
  }

  Future<Null> _clearTextController(BuildContext context, TextEditingController _controller, FocusNode node) async {
    Future.delayed(Duration(milliseconds: 50), () {
      setState(() {
        _controller.clear();
      });
      FocusScope.of(context).requestFocus(node);
    });
  }


  Future<Null> _postTransaction(DateTime date) async {
    final api = Api();

    int len = _stockInputControllers.length;
    List<String> _bodyList = [];

    List<String> _stockCodeList = [];
    List<String> _stockNameList = [];
    List<String> _uomValueList1 = [];
    List<String> _uomValueList2 = [];

    for(int i = 0; i < len; i++) {
      _stockCodeList.add(_stockInputControllers[i].text);
      _stockNameList.add(_stockNames[i]);
      _uomValueList1.add(_lvl1InputControllers[i].text);
      _uomValueList2.add(_lvl2InputControllers[i].text);
    }

    for(int i = 0; i < len; i++) {
      Details details1 = Details(
        numbering: null,
        stock: _stockInputControllers[i].text,
        pos: 2,
        description: dropdownValue.split('. ')[1],
        price: 0,
        uom: _uomValueList1[i],
        qty: int.parse(_lvl1InputControllers[i].text),
        amount: 1,
        note: null,
        costCentre: null,
        project: "Serdang",
        stockLocation: "HQ",
      );

      Details details2 = Details(
        numbering: null,
        stock: _stockInputControllers[i].text,
        pos: 1,
        description: dropdownValue.split('. ')[1],
        price: 0,
        uom: _uomValueList2[i], // ??? Questionable
        qty: _lvl2InputControllers[i].text == '' ? 0 : int.parse(_lvl2InputControllers[i].text),
        amount: 1,
        note: null,
        costCentre: null,
        project: "Serdang",
        stockLocation: "HQ",
      );

      if (_lvl1InputControllers[i].text != '' && _lvl2InputControllers[i].text != '') {
        detail = [details1, details2];
      } else if(_lvl1InputControllers[i].text != '') {
        detail = [details1];
      } else {
        print("Empty #$i");
      }

      // With API, it gathers all the data, and make the POST request to the server
      // Have to add multiple post requests.

      StockIn firstData = new StockIn(
        stockInCode: trxNumber,
        stockInDate: DateFormat("yyyy-MM-dd").format(date),
        description: dropdownValue.split('. ')[1],
        referenceNo: null,
        title: "Test",
        isCancelled: false,
        notes: null,
        costCentre: null,
        project: "Serdang",
        stockLocation: "HQ",
        details: detail,
      );

      var body = jsonEncode(firstData.toJson());
      print("Object to send: $body");
      print("Other status: $dbCode, ${_url}StockIns");

      _bodyList.add(body);

      // final api = Api();
      // await api.postStockIns(dbCode, body, _url).then((_){
      //   print("Post request is done!");
      // });
    }

    await api.postMultipleStockIns(dbCode, _bodyList, '${_url}StockIns').then((_){
      print("Post requests are done!");
    });

  }

  Future<Null> _saveTheDraft(DateTime createdDate) async {
    int len = _stockInputControllers.length;

    List<String> _stockCodeList = [];
    List<String> _stockNameList = [];
    List<String> _uomValueList1 = [];
    List<String> _uomValueList2 = [];
    List<String> _otherList = [];

    for(int i = 0; i < len; i++) {
      _stockCodeList.add(_stockInputControllers[i].text);
      _stockNameList.add(_stockNames[i]);
      _uomValueList1.add(_lvl1InputControllers[i].text);
      _uomValueList2.add(_lvl2InputControllers[i].text);
    }

    _otherList.add(createdDate.toString());
    _otherList.add(trxNumber);
    _otherList.add(dropdownValue);

    List<String> draftBank = await FileManager.getDraftList();
    String index = '${draftBank.length}';
    String draftName = '$trxNumber';
    // Saving new draft list to Draft Bank for the Draft list page.
    FileManager.saveDraftList(draftName);
    print('Draft names: draft_stockCode_$index, draft_stockName_$index');

    FileManager.saveDraft('draft_stockCode_$index', _stockCodeList);
    FileManager.saveDraft('draft_stockName_$index', _stockNameList);
    FileManager.saveDraft('draft_lvl1uom_$index', _uomValueList1);
    FileManager.saveDraft('draft_lvl2uom_$index', _uomValueList2);
    FileManager.saveDraft('draft_lvl1uomCode_$index', _lvl1uomList);
    FileManager.saveDraft('draft_lvl2uomCode_$index', _lvl2uomList);
    FileManager.saveDraft('draft_other_$index', _otherList);
    // FileManager.saveDraft('draft_baseUoms_$index', _lvl1uomList);
    // Save the UOM type name to the list as draft_baseUomsLvl1_$index

  }

  Future<bool> _deleteRow(int index) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Do you want to delete #${index + 1} row?"),
        actions: <Widget>[
          FlatButton(
            child: Text('Yes'),
            onPressed: () {
              print('Yes clicked');
              setState(() {
                _lvl1uomList.removeAt(index);
                _lvl2uomList.removeAt(index);
                _stockNames.removeAt(index);
                _stockInputControllers.removeAt(index);
                _lvl1InputControllers.removeAt(index);
                _lvl2InputControllers.removeAt(index);

                _stockInputNodes.removeAt(index);
                _lvl1InputNodes.removeAt(index);
                _lvl2InputNodes.removeAt(index);
                if(index == 0) {
                  setState(() {
                    _isButtonDisabled = true;
                  });
                }
              });
              Navigator.pop(context, true);
            },
          ),
          FlatButton(
            child: Text('No'),
            onPressed: () {
              print('No clicked');
              Navigator.pop(context, true);
            },
          ),
        ],
      )
    );
  }

  Future<Null> setInitials() async {
    DateTime currentDate = DateTime.now();
    String cdate = DateFormat("yyMMdd").format(currentDate);

    // Comparing the new trx number and old trx number for renewal
    String savedTrxDate = await FileManager.getTrxDate();
    int numbering = await FileManager.getTrxNumbering();
    if(cdate == savedTrxDate) {
      FileManager.setTrxNumbering(numbering + 1);
      ++numbering;
    } else {
      FileManager.setTrxNumbering(0);
      numbering = 0;
      FileManager.setTrxDate(cdate);
    }


    _descripts = await FileManager.readDescriptions();
    print("Descripts: $_descripts");

    setState(() {
      dropdownValue = _descripts[0];
      _descriptions = _descripts;
    });

    setState(() {
      if(numbering < 10) {
        trxNumber = 'SIN${DateFormat("yyMMdd").format(currentDate)}/00$numbering';
      } else if(numbering < 100 && numbering >= 10) {
        trxNumber = 'SIN${DateFormat("yyMMdd").format(currentDate)}/0$numbering';
      } else {
        trxNumber = 'SIN${DateFormat("yyMMdd").format(currentDate)}/$numbering';
      }

      _lvl1uomList.add('Unit');
      _lvl2uomList.add('Unit');
      _stockNames.add('StockCode');
      _stockInputControllers.add(new TextEditingController());
      _lvl1InputControllers.add(new TextEditingController());
      _lvl2InputControllers.add(new TextEditingController());

      _stockInputNodes.add(new FocusNode());
      _lvl1InputNodes.add(new FocusNode());
      _lvl2InputNodes.add(new FocusNode());
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    setInitials();
    initServerUrl();
  }

  @override
  Widget build(BuildContext context) {
    DateTime createdDate = DateTime.now();


    Widget deleteRowButton(int index) {
      return Padding(
        padding: EdgeInsets.all(5),
        child: MaterialButton(
          onPressed: () {
            // delete current row
            print("Clicked row index: $index");
            _deleteRow(index);
          },
          child: Icon(
            Icons.delete,
            color: Colors.red,
            size: 30,
          ),
          // shape: StadiumBorder(),
          // color: Colors.teal[300],
          splashColor: Colors.grey,
          // height: 50,
          // minWidth: 250,
          elevation: 2,
        ),
      );
    }

    Widget _stockMeasurement(int index, TextEditingController _lvl1Controller, TextEditingController _lvl2Controller, FocusNode _lvl1Node, FocusNode _lvl2Node) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.all(2.0),
              child: Container(
                height: 30,
                child: TextFormField(
                    style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF004B83),
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration.collapsed(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: '  lvl1: ${_lvl1uomList[index]}',
                    hintStyle: TextStyle(
                      color: Color(0xFF004B83),
                      fontWeight: FontWeight.w200,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  autofocus: false,
                  controller: _lvl1Controller,
                  focusNode: _lvl1Node,
                  onTap: () {
                    _focusNode(context, _lvl1Node);
                    // _clearTextController(context, _lvl1Controller, _lvl1Node);
                  },
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              _lvl1uomList[index],
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF004B83),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Container(
                height: 30,
                child: TextFormField(
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF004B83),
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration.collapsed(
                    filled: true,
                    fillColor: Colors.white,
                    hintText:'  lvl2: ${_lvl2uomList[index]}',
                    hintStyle: TextStyle(
                      color: Color(0xFF004B83),
                      fontWeight: FontWeight.w200,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  enabled: _isUOMEnabledList[index],
                  autofocus: false,
                  controller: _lvl2Controller,
                  focusNode: _lvl2Node,
                  onTap: () {
                    _focusNode(context, _lvl2Node);
                    // _clearTextController(context, _lvl2Controller, _lvl2Node);
                  },
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              _lvl2uomList[index],
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF004B83),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: deleteRowButton(index),
          )
        ],
      );
    }

    Widget _stockInput(int index, TextEditingController _controller, FocusNode _stockNode) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Text(
              'StockIn: ${index + 1}',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF004B83),
                fontWeight: FontWeight.bold,
              ),
            )
          ),
          Expanded(
            flex: 8,
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Container(
                height: 40,
                child: TextFormField(
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF004B83),
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Stock code',
                    hintStyle: TextStyle(
                      color: Color(0xFF004B83),
                      fontWeight: FontWeight.w200,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    errorStyle: TextStyle(
                      color: Colors.yellowAccent,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(EvaIcons.close,
                        color: Colors.blueAccent,
                        size: 24,
                      ),
                      onPressed: () {
                        _clearTextController(context, _controller, _stockNode);
                      },
                    ),
                  ),
                  autofocus: false,
                  controller: _controller,
                  focusNode: _stockNode,
                  onTap: () {
                    _focusNode(context, _stockNode);
                  },
                  onChanged: (value) {
                    _stockInEventListener(index, _controller);
                  },
                ),
              ),
            ),
          ),
        ],
      );
    }

    final addStockInputButton = Center(
      child: Padding(
        padding: EdgeInsets.all(10),
        child: MaterialButton(
          onPressed: () {
            setState(() {
              _lvl1uomList.add('');
              _lvl2uomList.add('');
              _stockNames.add('');
              _isUOMEnabledList.add(false);
              _stockInputControllers.add(new TextEditingController());
              _lvl1InputControllers.add(new TextEditingController());
              _lvl2InputControllers.add(new TextEditingController());

              _stockInputNodes.add(new FocusNode());
              _lvl1InputNodes.add(new FocusNode());
              _lvl2InputNodes.add(new FocusNode());
            });
          },
          child: Icon(
            EvaIcons.plusCircleOutline,
            color: Colors.blueGrey,
            size: 40,
          ),
          // shape: StadiumBorder(),
          // color: Colors.lightBlue[600],
          splashColor: Colors.teal,
          height: 50,
          // minWidth: MediaQuery.of(context).size.width / 2,
          elevation: 2,
        ),
      ),
    );

    final postButton = Center(
      child: Padding(
        padding: EdgeInsets.all(10),
        child: MaterialButton(
          onPressed: _isButtonDisabled ? null : () {
            // gather all the information and post data to db by api lib.
            /// Check process and post Transaction
            bool _completed = true;
            int index = 0;
            _stockInputControllers.forEach((controller) async {
              if (_isUOMEnabledList[index] == false) {
                if(controller.text != '' && _lvl1InputControllers[index].text != '') {
                  _completed = _completed && true;
                } else {
                  _completed = false;
                }
              } else {
                if(controller.text != ''
                  && _lvl1InputControllers[index].text != ''
                  && _lvl2InputControllers[index].text != '') {
                  _completed = _completed && true;
                } else {
                  _completed = false;
                }
              }
              index++;
            });

            if(_completed) {
              return showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("Do you want to upload the transactions?"),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('Yes'),
                      onPressed: () {
                        if(!postClicked) {
                          print('Yes clicked');
                          _postTransaction(createdDate).then((_) {
                            Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
                          });
                          setState(() {
                            postClicked = true;
                          });
                        }
                      },
                    ),
                    FlatButton(
                      child: Text('No'),
                      onPressed: () {
                        print('No clicked');
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                )
              );
            } else {
              return showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("Please fill all input fieds"),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('Okay'),
                      onPressed: () {
                        print('Ok clicked');
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                )
              );
            }
          },
          child: Text(
            'Complete Trx',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'QuickSand',
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          shape: StadiumBorder(),
          color: Colors.teal[300],
          splashColor: Colors.green[50],
          height: 40,
          minWidth: 140,
          elevation: 2,
        ),
      ),
    );


    Widget _saveDraftButton(BuildContext context) {
      return Padding(
        padding: EdgeInsets.all(5),
        child: MaterialButton(
          onPressed: _isButtonDisabled ? null : () {
            print('You pressed Draft Button!');
            _saveTheDraft(createdDate).then((_){

              Alert(
                context: context,
                type: AlertType.success,
                title: "StockIn draft is saved successfully",
                desc: "Current page will be deleted now.",
                buttons: [
                  DialogButton(
                    child: Text(
                      "OK",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    onPressed: () => Navigator.of(context).pushReplacementNamed(HomeScreen.routeName),
                    width: 120,
                  )
                ],
              ).show();
            });

          },
          child: Text(
            'Save as Draft',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'QuickSand',
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          shape: StadiumBorder(),
          color: Colors.orange[800],
          splashColor: Colors.yellow[200],
          height: 40,
          minWidth: 100,
          elevation: 2,
        )
      );
    }

    Widget _descriptionMenu(BuildContext context, String header) {
      return Row(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: Text(
              '$header',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF004B83),
                fontWeight: FontWeight.bold
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: Container(
                child: DropdownButton<String>(
                  value: dropdownValue,
                  icon: Icon(EvaIcons.arrowDownOutline),
                  iconSize: 24,
                  elevation: 16,
                  style: TextStyle(color: Colors.deepPurple),
                  underline: Container(
                    height: 2,
                    color: Colors.deepPurpleAccent,
                  ),
                  onChanged: (String newValue) {
                    setState(() {
                      dropdownValue = newValue;
                    });
                    // Add some functions to handle change.
                  },
                  items: _descriptions.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      );
    }

    Widget statusBar(String time) {
      return Padding(
        padding: const EdgeInsets.only(left: 2, right: 2),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 3,
              child: Text(
                time,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'QuickSand',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ),
            Expanded(
              flex: 7,
              child: Text(
                'System Auto: $trxNumber',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: 'QuickSand',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget buildContainer(Widget child) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5)
        ),
        margin: EdgeInsets.all(5),
        padding: EdgeInsets.all(5),
        height: 350,
        width: 400,
        child: child,
      );
    }


    final transaction = GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            statusBar(DateFormat("yyyy/MM/dd HH:mm:ss").format(createdDate)),
            // descriptionMenu,
            // stockParameters,
            _descriptionMenu(context, 'Description:'),
            new Divider(height: 20.0, color: Colors.black87,),

            buildContainer(
              ListView.builder(
                itemCount: _stockInputControllers?.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    padding: const EdgeInsets.all(4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        _stockInput(index, _stockInputControllers[index], _stockInputNodes[index]),
                        Text('Stock Name: ${_stockNames[index]}'),
                        _stockMeasurement(index, _lvl1InputControllers[index], _lvl2InputControllers[index], _lvl1InputNodes[index], _lvl2InputNodes[index]),
                        new Divider(height: 15.0,color: Colors.black87,),
                      ],
                    ),
                  );
                },
              ),
            ),
            addStockInputButton,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  child: postButton,
                ),
                Expanded(
                  child: _saveDraftButton(context),
                )
              ],
            ),
          ],
        ),
      ),
    );


    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if(constraints.maxHeight > constraints.maxWidth) {
          return SingleChildScrollView(
            child: transaction,
          );
        } else {
          return Center(
            child: Container(
              width: 450,
              child: transaction,
            ),
          );
        }
      },
    );
  }
}
