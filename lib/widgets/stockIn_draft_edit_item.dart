import 'dart:convert';

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../model/uoms.dart';
import '../screens/home_screen.dart';
import '../screens/stockIn_draft_screen.dart';
import '../helper/database_helper.dart';
import '../helper/file_manager.dart';
import '../helper/api.dart';
import '../model/stockIn.dart';

class StockInDraftEditTransaction extends StatefulWidget {
  @override
  _StockInDraftEditTransactionState createState() => _StockInDraftEditTransactionState();
}

class _StockInDraftEditTransactionState extends State<StockInDraftEditTransaction> {

  final dbHelper = DatabaseHelper.instance;
  bool _isButtonDisabled = true;
  bool _isDraftButtonDisabled = false;

  final _refController = new TextEditingController();
  List<TextEditingController> _stockInputControllers = new List();
  List<TextEditingController> _lvl1InputControllers = new List();
  List<TextEditingController> _lvl2InputControllers = new List();

  FocusNode _refNode = new FocusNode();
  List<FocusNode> _stockInputNodes = new List();
  List<FocusNode> _lvl1InputNodes = new List();
  List<FocusNode> _lvl2InputNodes = new List();

  String trxNumber = '';
  String stockId = '';

  String projectCode = '';
  String location = '';

  String statusTime = '';

  List<String> _lvl1uomList = [];
  List<String> _lvl2uomList = [];
  List<String> _stockNames = [];
  List<Uoms> uomList = [];
  List<Details> detail = [];

  DateTime draftCreatedAt;

  // For the buffering from the saved and indexed values
  List<String> _otherList = [];
  List<String> _stockCodeList = [];
  List<String> _stockNameList = [];

  
  List<bool> _isUOMEnabledList = [];
  // Dropdown menu variables
  List<String> _descriptions = [];
  List<String> _descripts = [];
  String dropdownValue = '';
  String buffer = '';
  String trueVal = '';

  String ip, port, dbCode;
  String urlStatus = 'not found';
  String _url = '';
  int draftIndex = 0;

  Future<Null> initServerUrl() async {
    ip =  await FileManager.readProfile('ip_address');
    port =  await FileManager.readProfile('port_number');
    dbCode =  await FileManager.readProfile('stock_company_name');
    if(ip != '' && port != '' && dbCode != '') {
      _url = 'http://$ip:$port/api/';
    } else {
      _url = 'https://dev-api.qne.cloud/api/';
      dbCode = 'OUCOP7';
    }
    setState((){
      urlStatus = _url;
    });
  }

  Future<Null> _searchStockCode(int index, String stockCode) async {
    bool isEmpty = false;
    bool isNetworkOk = false;
    List<Map> stockData = await dbHelper.queryAllRows();
    final api = Api();
    List<String> uoms = [];

    var currentStock = stockData.where((row) => row["stockCode"] == stockCode);
    currentStock.forEach((row) async {
      if (row["stockCode"] == stockCode) {
        print('ID: ${row["id"]}');
        _stockNames[index] = (row["stockName"]);

        isEmpty = isEmpty || true;
        print('I got this :)');
        // _lvl1InputControllers[index].text = row["baseUOM"];

        // this will build baseUOM lvl1, lvl2 widgets
        stockId = row["stockId"];
        //Fetching Unit of Measurements for the Stock.
        var data = await api.getStocks(dbCode, '${_url}Stocks/$stockId/UOMS');
        print('Received UOM data: $data');
        if(data != 'SocketException') {
          isNetworkOk = true;
          var receivedData = json.decode(data);
          uomList =
              receivedData.map<Uoms>((json) => Uoms.fromJson(json)).toList();
          print("Length UOMs: ${uomList.length}");
          setState(() {
            if (uomList.length > 1) {
              uomList.forEach((uom) {
                if(uom.isBaseUOM == true) {
                  _lvl1uomList[index] = uom.uomCode;
                  // uomList.remove(uom);
                } else {
                  uoms.add(uom.uomCode);
                }
              });
              uoms.sort();
              _lvl2uomList[index] = uoms[0];
              
              _lvl1InputControllers[index].text = '0';
              _lvl2InputControllers[index].text = '0';
              _isUOMEnabledList[index] = true;
              // enable both lvl1 and lvl2 input fields
            } else {
              _lvl1uomList[index] = uomList[0].uomCode;
              _lvl1InputControllers[index].text = '0';
              _lvl2uomList[index] = '';
              // disable lvl2 input field
              _isUOMEnabledList[index] = false;
            }
          });
        } else {
          isNetworkOk = false;
          Scaffold.of(context).showSnackBar(SnackBar(
              content: new Text(
                "Network is not available! Please check the network.",
                textAlign: TextAlign.center,
              ),
              duration: const Duration(milliseconds: 3000),
            ),
          );
        }
      } else {
        isEmpty = isEmpty || false;
      }
    });

    if(!isEmpty && isNetworkOk == true) {
      Scaffold.of(context).showSnackBar(SnackBar(
          content: new Text(
            "StockCode is not available! Please try again.",
            textAlign: TextAlign.center,
          ),
          duration: const Duration(milliseconds: 2000),
        ),
      );
    }


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

      await Future.delayed(const Duration(milliseconds: 500), () {
        _stockInputControllers[index].text = trueVal;
      }).then((value) {
        _searchStockCode(index, trueVal);
        Future.delayed(const Duration(milliseconds: 500), () {
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


  Future<String> _postTransaction(DateTime date) async {
    final api = Api();

    int len = _stockInputControllers.length;

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

    for (int i = 0; i < len; i++) {
      Details details1 = Details(
        numbering: null,
        stock: _stockInputControllers[i].text,
        pos: 2,
        description: _stockNames[i],
        price: 0,
        uom: _lvl1uomList[i],
        qty: int.parse(_lvl1InputControllers[i].text),
        amount: 1,
        note: null,
        costCentre: null,
        project: projectCode,
        stockLocation: location,
      );

      Details details2 = Details(
        numbering: null,
        stock: _stockInputControllers[i].text,
        pos: 1,
        description: _stockNames[i],
        price: 0,
        uom: _lvl2uomList[i], // ??? Questionable
        qty: _lvl2InputControllers[i].text == ''
            ? 0
            : int.parse(_lvl2InputControllers[i].text),
        amount: 1,
        note: null,
        costCentre: null,
        project: projectCode,
        stockLocation: location,
      );
      // add stock code data one by one
      
      if (_lvl1InputControllers[i].text != '' &&
          _lvl2InputControllers[i].text != '') {
            detail.add(details1);
            detail.add(details2);
      } else if (_lvl1InputControllers[i].text != '') {
        detail.add(details1);
      } else {
        print("Empty #$i");
      }
    }

      // With API, it gathers all the data, and make the POST request to the server
      // Have to add multiple post requests.

      StockIn data = new StockIn(
        stockInCode: trxNumber,
        stockInDate: DateFormat("yyyy-MM-dd").format(date),
        description: dropdownValue.split('. ')[1],
        referenceNo: '${_refController.text}',
        title: dropdownValue.split('. ')[1],
        isCancelled: false,
        notes: null,
        costCentre: null,
        project: projectCode,
        stockLocation: location,
        details: detail,
      );

      var body = jsonEncode(data.toJson());
      print("Object to send: $body");
      print("Other status: $dbCode, ${_url}StockIns");


    String result = '';
    await api.postStockIns(dbCode, body, '${_url}StockIns').then((resCode){
      if(resCode == 'SocketError') {
        result = 'SocketError';
      } else {
        if(resCode == '200') {
          result = '$len/$len';
        }
      }
      print("Result: $result");
    });

    return result;
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

    _otherList.add(draftCreatedAt.toString());
    _otherList.add(trxNumber);
    _otherList.add(dropdownValue.split('. ')[0]); // saving index value of dropdown list
    _otherList.add(_refController.text);

    int draftIndex = await FileManager.getSelectedIndex();
    String index = draftIndex.toString();
    // Saving draft list to Draft Bank for the Draft list page.

    // Draft updating feature started
    print('Draft names: draft_stockCode_$index, draft_stockName_$index');

    FileManager.saveDraft('draft_stockCode_$trxNumber', _stockCodeList);
    FileManager.saveDraft('draft_stockName_$trxNumber', _stockNameList);
    FileManager.saveDraft('draft_lvl1uom_$trxNumber', _uomValueList1);
    FileManager.saveDraft('draft_lvl2uom_$trxNumber', _uomValueList2);
    FileManager.saveDraft('draft_lvl1uomCode_$trxNumber', _lvl1uomList);
    FileManager.saveDraft('draft_lvl2uomCode_$trxNumber', _lvl2uomList);
    FileManager.saveDraft('draft_other_$trxNumber', _otherList);

  }

  Future<bool> _deleteRow(int index) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Do you want to delete #${index + 1} row?",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),        
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('Yes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF004B83),),),
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
            child: Text('No', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF004B83),),),
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
    List<String> _uomValueList1 = [];
    List<String> _uomValueList2 = [];
    // =============== GET SELECTED DRAFT LIST VALUE ============== //
    projectCode = await FileManager.readProfile('project_code');
    location = await FileManager.readProfile('location');

    draftIndex = await FileManager.getSelectedIndex();
    List<String> draftBank = await FileManager.getDraftBank();
    String trxName = draftBank[draftIndex];
    _otherList = await FileManager.readDraft('draft_other_$trxName');
    print('Other list: ${_otherList[1]}, sel: $trxName');
    _stockCodeList = await FileManager.readDraft('draft_stockCode_$trxName');
    _stockNameList = await FileManager.readDraft('draft_stockName_$trxName');
    _uomValueList1 = await FileManager.readDraft('draft_lvl1uom_$trxName');
    _uomValueList2 = await FileManager.readDraft('draft_lvl2uom_$trxName');
    _lvl1uomList = await FileManager.readDraft('draft_lvl1uomCode_$trxName');
    _lvl2uomList = await FileManager.readDraft('draft_lvl2uomCode_$trxName');
    _descripts = await FileManager.readDescriptions();

    String devName = await FileManager.readProfile("device_name_api");
    if(devName == '') {
      devName = '*';
    }

    int index = 0;
    if(_otherList[2] != '' || _otherList[2] != null) {
      index = int.parse(_otherList[2]) - 1;
      if(index < 0) {
        index = 0;
      }
    } else {
      index = 0;
    }
    setState(() {
      dropdownValue = _descripts[index];
      _descriptions = _descripts;
    });

    // Now Extracting Saved String List values to the fields based on index
    DateTime draftDate = DateTime.parse(_otherList[0]);

    setState(() {
      draftCreatedAt = draftDate;
      statusTime = DateFormat("yyyy/MM/dd HH:mm:ss").format(draftDate);
      trxNumber = '$devName-${_otherList[1]}';
      _refController.text = _otherList[3];
      for(int i = 0; i < _stockCodeList.length; i++) {
        print('Adding!');
        _stockInputControllers.add(new TextEditingController());
        _lvl1InputControllers.add(new TextEditingController());
        _lvl2InputControllers.add(new TextEditingController());
        _stockNames.add('');
        _isUOMEnabledList.add(false);

        // Complete & Draft button enabling logic is here
        if(_stockCodeList[i] != '' && (_uomValueList1[i] != '' || _uomValueList2[i] != '')
          && _stockNameList[i] != 'StockCode' && _lvl1uomList[i] != 'Unit') {
          _isButtonDisabled = false;
          print('All requirements are filled');
        }
        if(_lvl2uomList[i] != '' && _lvl2uomList[i] != 'Unit') {
          _isUOMEnabledList[i] = true;
        }

        _stockInputControllers[i].text = _stockCodeList[i];
        _lvl1InputControllers[i].text = _uomValueList1[i];
        _lvl2InputControllers[i].text = _uomValueList2[i];
        _stockNames[i] = _stockNameList[i];

        _stockInputNodes.add(new FocusNode());
        _lvl1InputNodes.add(new FocusNode());
        _lvl2InputNodes.add(new FocusNode());
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    for(int i = 0; i < _stockInputControllers.length; i++) {
      _stockInputControllers[i].dispose();
      _lvl1InputControllers[i].dispose();
      _lvl2InputControllers[i].dispose();
    }
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

    Widget responseStatus(bool status, String value) {
      Alert(
        context: context,
        type: status == true ? AlertType.success : AlertType.error,
        title: "Response Status: $value",
        desc: status == true ? "Current page will be deleted now." : "Please check internet connection or settings parameters",
        buttons: [
          DialogButton(
            child: Text(
              "OK",
              style:
                  TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () => status == true ? Navigator.of(context)
              .pushReplacementNamed(
                  StockInDraftScreen.routeName) : Navigator.of(context).pop(),
            width: 120,
          )
        ],
      ).show();
      return null;
    }

    Widget deleteRowButton(int index) {
      return MaterialButton(
        onPressed: () {
          // delete current row
          print("Clicked row index: $index");
          _deleteRow(index);
          _isDraftButtonDisabled = false;
        },
        child: Icon(
          Icons.delete,
          color: Colors.red,
          size: 32,
        ),
        // shape: StadiumBorder(),
        // color: Colors.teal[300],
        splashColor: Colors.grey,
        // height: 50,
        // minWidth: 250,
        elevation: 2,
      );
    }

    Widget _stockMeasurement(
        int index,
        TextEditingController _lvl1Controller,
        TextEditingController _lvl2Controller,
        FocusNode _lvl1Node,
        FocusNode _lvl2Node) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            flex: 6,
            child: Padding(
              padding: EdgeInsets.only(left: 12, right: 2),
              child: Container(
                height: 40,
                child: TextFormField(
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF004B83),
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: '${_lvl1uomList[index]}',
                    hintStyle: TextStyle(
                      color: Color(0xFF004B83),
                      fontWeight: FontWeight.w200,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    contentPadding: EdgeInsets.all(4),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  autofocus: false,
                  controller: _lvl1Controller,
                  focusNode: _lvl1Node,
                  onTap: () {
                    // _focusNode(context, _lvl1Node);
                    _clearTextController(context, _lvl1Controller, _lvl1Node);
                  },
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              _lvl1uomList[index],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: Color(0xFF004B83),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 10,),
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.only(left: 2, right: 2),
              child: Container(
                height: 40,
                child: TextFormField(
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF004B83),
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: '${_lvl2uomList[index]}',
                    hintStyle: TextStyle(
                      color: Color(0xFF004B83),
                      fontWeight: FontWeight.w200,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    contentPadding: EdgeInsets.all(4),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  enabled: _isUOMEnabledList[index],
                  autofocus: false,
                  controller: _lvl2Controller,
                  focusNode: _lvl2Node,
                  onTap: () {
                    // _focusNode(context, _lvl2Node);
                    _clearTextController(context, _lvl2Controller, _lvl2Node);
                  },
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              _lvl2uomList[index],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: Color(0xFF004B83),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: deleteRowButton(index),
          )
        ],
      );
    }

    Widget _stockInput(
        int index, TextEditingController _controller, FocusNode _stockNode) {
      return Padding(
        padding: const EdgeInsets.only(left: 12, right: 12, top: 3, bottom: 3),
        child: Container(
          height: 45,
          child: TextFormField(
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFF004B83),
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: '${index + 1}. Stock code',
              hintStyle: TextStyle(
                color: Color(0xFF004B83),
                fontWeight: FontWeight.w400,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              errorStyle: TextStyle(
                color: Colors.yellowAccent,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  EvaIcons.close,
                  color: Colors.blueAccent,
                  size: 20,
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
              // _clearTextController(context, _controller, _stockNode);
            },
            onChanged: (value) {
              _stockInEventListener(index, _controller);
            },
          ),
        ),
      );
    }

    final referenceInput = Container(
      height: 30,
      width: 150,
      child: Center(
        child: TextFormField(
          textAlignVertical: TextAlignVertical.bottom,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF004B83),
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: 'Reference',
            hintStyle: TextStyle(
              color: Color(0xFF004B83),
              fontWeight: FontWeight.w200,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
          autofocus: false,
          controller: _refController,
          focusNode: _refNode,
          onTap: () {
            _focusNode(context, _refNode);
            // _clearTextController(context, _controller, _stockNode);
          },
        ),
      ),
    );


    final addStockInputButton = Center(
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
          size: 30,
        ),
        // shape: StadiumBorder(),
        // color: Colors.lightBlue[600],
        splashColor: Colors.teal,
        height: 30,
        // minWidth: MediaQuery.of(context).size.width / 2,
        elevation: 2,
      ),
    );

    final postButton = MaterialButton(
      onPressed: _isButtonDisabled ? null : () {
        // gather all the information and post data to db by api lib.
        /// Check process and post Transaction
        String pattern = trxNumber.split('-')[0];
        bool _completed = true;
        int index = 0;
        _stockInputControllers.forEach((controller) async {
          if (_isUOMEnabledList[index] == false) {
            if(pattern != '*' && _refController.text != '' && controller.text != '' && dropdownValue.split('. ')[1] != ''
              && _lvl1InputControllers[index].text != '') {
              _completed = _completed && true;
            } else {
              _completed = false;
            }
          } else {
            if(pattern != '*' && _refController.text != '' && controller.text != '' && dropdownValue.split('. ')[1] != ''
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
                title: Text(
                  "Do you want to upload the transactions?"),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Yes'),
                    onPressed: () {
                      // Navigator.of(context).pop();
                      print('Yes clicked');
                      _postTransaction(createdDate).then((value) {
                        print('From show dialog: $value');
                        if(value.isNotEmpty && value != '' && value != 'SocketError') {
                          var res = value.split('/')[0];
                          var len = value.split('/')[1];
                          if(res == len) {
                            responseStatus(true, value);
                            // All process is done for draft. Now deleting
                            FileManager.removeDraft('draft_other_$draftIndex');
                            FileManager.removeDraft('draft_stockCode_$draftIndex');
                            FileManager.removeDraft('draft_stockName_$draftIndex');
                            FileManager.removeDraft('draft_lvl1uom_$draftIndex');
                            FileManager.removeDraft('draft_lvl2uom_$draftIndex');
                            FileManager.removeDraft('draft_lvl1uomCode_$draftIndex');
                            FileManager.removeDraft('draft_lvl2uomCode_$draftIndex');
                            FileManager.removeFromBank(draftIndex);
                            // Navigator.of(context).pushReplacementNamed(StockInDraftScreen.routeName);

                          } else {
                            responseStatus(false, value);
                          }
                        } else {
                          responseStatus(false, value);
                        }
                        // Navigator.pop(context);
                      });
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
              ));
        } else {
          return showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("Please fill all input fields or device parameters", 
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),                          
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('Okay'),
                  onPressed: () {
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
      height: 25,
      minWidth: 130,
      elevation: 2,
    );


    Widget _saveDraftButton(BuildContext context) {
      return MaterialButton(
        onPressed: _isDraftButtonDisabled ? null : () {
          return showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(
                  "Do you want to save the draft again?"),
              actions: <Widget>[
                FlatButton(
                  child: Text('Yes'),
                  onPressed: () {
                    print('You pressed Draft Button!');
                    _saveTheDraft(createdDate).then((_) {
                      Alert(
                        context: context,
                        type: AlertType.success,
                        title: "StockIn draft is saved successfully",
                        desc: "Current page will be deleted now.",
                        buttons: [
                          DialogButton(
                            child: Text(
                              "OK",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                            onPressed: () => Navigator.of(context)
                                .pushReplacementNamed(StockInDraftScreen.routeName),
                            width: 120,
                          )
                        ],
                      ).show();
                    });
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
            ));
        },
        child: Text(
          'Save Draft',
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
        height: 25,
        minWidth: 130,
        elevation: 2,
      );
    }

    Widget _descriptionMenu(BuildContext context) {
      return Padding(
        padding: const EdgeInsets.only(right: 6.0, left: 6.0),
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
            items: _descriptions
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
      );
    }

    Widget statusBar(String time) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Text(
            '$time',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'QuickSand',
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.black,
            ),
          ),
          Text(
            '$trxNumber',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'QuickSand',
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.black,
            ),
          ),
        ],
      );
    }


    final transaction =  <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Flexible(
              fit: FlexFit.tight,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  statusBar(statusTime),
                  referenceInput,
                  _descriptionMenu(context),
                ],
              ),
            ),
            Flexible(
            flex: 1,
            fit: FlexFit.tight,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    height: 35,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: postButton,
                    ),
                  ),
                  SizedBox(
                    height: 35,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: _saveDraftButton(context),
                    ),
                  ),
                  SizedBox(
                    height: 35,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: addStockInputButton,
                    ),
                  ),                        
                ],
              ),
            ),
          ],
        ),
        new Divider(
          height: 5.0,
          color: Colors.black87,
        ),
        Expanded(
          child: ListView.builder(
              itemCount: _stockInputControllers?.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  padding: const EdgeInsets.all(4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      _stockInput(index, _stockInputControllers[index],
                          _stockInputNodes[index]),
                      Text('${_stockNames[index]}'),
                      _stockMeasurement(
                          index,
                          _lvl1InputControllers[index],
                          _lvl2InputControllers[index],
                          _lvl1InputNodes[index],
                          _lvl2InputNodes[index]),
                      new Divider(
                        height: 15.0,
                        color: Colors.black87,
                      ),
                    ],
                  ),
                );
              },
            ),
        ),
      ];

    return Column(
      // shrinkWrap: true,
      // padding: const EdgeInsets.only(left: 2, right: 2),
      children: transaction
    );
  }
}
