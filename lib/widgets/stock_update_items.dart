import 'dart:convert';

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../helper/api.dart';
import '../helper/database_helper.dart';
import '../helper/file_manager.dart';

class Transaction extends StatefulWidget {
  @override
  _TransactionState createState() => _TransactionState();
}

class _TransactionState extends State<Transaction> {
  final dbHelper = DatabaseHelper.instance;
  
  final _stockInputController = TextEditingController();
  final _ctnInputController = TextEditingController();
  final _pcsInputController = TextEditingController();

  FocusNode _stockInputNode = FocusNode();
  FocusNode _ctnInputNode = FocusNode();
  FocusNode _pcsInputNode = FocusNode();

  // List<TextEditingController> _stockInputController = new List();
  // List<TextEditingController> _ctnInputController = new List();
  // List<TextEditingController> _pcsInputController = new List();

  // List<FocusNode> _stockInputNode = new List();
  // List<FocusNode> _ctnInputNode = new List();
  // List<FocusNode> _pcsInputNode = new List();

  List<Widget> _children = [];
  int _count = 0;

  List<String> _descriptions = [];
  List<String> _descripts = [];
  String dropdownValue = '';
  String buffer = '';
  String trueVal = '';
  // <String>['One from the world, you know it', 'Two', 'Free', 'Four']

  Future<Null> _searchStockCode(String stockCode) async {

    List<Map> stockData = await dbHelper.queryAllRows();

    stockData.forEach((row){
      if(row["stockCode"] == stockCode) {
        print('ID: ${row["id"]}');
        int id = row["id"];
        _ctnInputController.text = row["baseUOM"];
        _pcsInputController.text = row["baseUOM"];
      }
    });

  }

  Future<Null> stockInListener() async {
    buffer = _stockInputController.text;
    if(buffer.endsWith(r'$')) {
      buffer = buffer.substring(0, buffer.length - 1);
      trueVal = buffer;


      await Future.delayed(const Duration(milliseconds: 1000), (){
        _stockInputController.text = trueVal;
      }).then((value){
        _searchStockCode(trueVal);
        Future.delayed(const Duration(milliseconds: 500), (){
          // _stockInputController.clear();
          _stockInputNode.unfocus();
          FocusScope.of(context).requestFocus(new FocusNode());
        });
      });
    }
  }

  Future<Null> _addButtonHandler(BuildContext context) async {
    print('I am clicked!');
    // final api = Api();
    // String data = await api.getStocks('OUCOP7');
    // List receivedData = json.decode(data);
    // for(int i = 0; i < receivedData.length; i++) {
    //   print('Fetched data: ${receivedData[i]["details"]}');
    // }
    // setState(() {
    //   _stockInputController.text = receivedData[0]["stockInCode"];
    //   _pcsInputController.text = receivedData[0]["UOM"].toString();
    // });

    _children = List.from(_children)
      ..add(TextFormField(
        decoration: InputDecoration(hintText: 'Text Field is added $_count'),
      ));
    setState(() {
      ++_count;
    });
    // run the api http request to the qne.cloud server
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

  Future<Null> setInitials() async {
    _descripts = await FileManager.readDescriptions();
    if(_descripts.isEmpty || _descripts == null) {
      setState(() {
        dropdownValue = 'Not Selected';
      });
      for(int i = 0; i < _descripts.length; i++) {
        setState(() {
          // _descriptionControllers[i].text = 'NaN';
          _descriptions[i] = '#$i. Not Available';
        });
      }
    } else {
      setState(() {
        dropdownValue = _descripts[0];
        _descriptions = _descripts;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _stockInputController.dispose();
  }

  @override
  void initState() {
    super.initState();
    _stockInputController.addListener(stockInListener);
    setInitials();
  }

  @override
  Widget build(BuildContext context) {
    DateTime createdDate = DateTime.now();
    

    final button = Center(
      child: Padding(
      padding: EdgeInsets.all(10),
      child: MaterialButton(
        onPressed: () {
          _addButtonHandler(context);
        },
        child: Icon(
          EvaIcons.plusCircleOutline,
          color: Colors.white,
          size: 40,
        ),
        shape: StadiumBorder(),
        color: Colors.blue,
        splashColor: Colors.teal,
        height: 40,
        minWidth: 40,
        elevation: 2,
      ),
    ),

      );

    Widget _stockInput(TextEditingController _controller, FocusNode _stockNode) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            flex: 4,
            child: Text(
              'Stock In:',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 20, 
                color: Color(0xFF004B83),
                fontWeight: FontWeight.bold,
              ),
            )
          ),
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Container(
                height: 60,
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
                ),
              ),
            ),
          ),
        ],
      );
    }

    Widget _descriptionMenu(BuildContext context, String header) {
      return Row(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Text(
              '$header',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF004B83),
                fontWeight: FontWeight.bold
              ),
            ),
          ),
          Expanded(
            flex: 7,
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
                'System Auto: SIN191200',
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

    Widget _stockMeasurement(TextEditingController _ctnController, TextEditingController _pcsController, FocusNode _ctnNode, FocusNode _pcsNode) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 4,
            child: Padding(
              padding: EdgeInsets.all(2.0),
              child: Container(
                height: 60,
                child: TextFormField(
                    style: TextStyle(
                    fontSize: 12, 
                    color: Color(0xFF004B83),
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'CTN',
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
                        size: 16,
                      ),
                      onPressed: () {
                        _clearTextController(context, _ctnController, _ctnNode);
                      },
                    ),
                  ),
                  autofocus: false,
                  controller: _ctnController,
                  focusNode: _ctnNode,
                  onTap: () {
                    _focusNode(context, _ctnNode);
                  },
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'CTN',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 20, 
                color: Color(0xFF004B83),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Container(
                height: 60,
                child: TextFormField(
                  style: TextStyle(
                    fontSize: 12, 
                    color: Color(0xFF004B83),
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'PCS',
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
                        size: 16,
                      ),
                      onPressed: () {
                        _clearTextController(context, _pcsController, _pcsNode);
                      },
                    ),
                  ),
                  autofocus: false,
                  controller: _pcsController,
                  focusNode: _pcsNode,
                  onTap: () {
                    _focusNode(context, _pcsNode);
                  },
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'PCS',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 20, 
                color: Color(0xFF004B83),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
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
        height: 450,
        width: 400,
        child: child,
      );  
    }

    final transaction = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        statusBar(DateFormat("yyyy/MM/dd HH:mm:ss").format(createdDate)),
        // descriptionMenu,
        // stockParameters,
        _descriptionMenu(context, 'Description:'),
        new Divider(height: 20.0, color: Colors.black87,),

        _stockInput(_stockInputController, _stockInputNode),

        _stockMeasurement(_ctnInputController, _pcsInputController, _ctnInputNode, _pcsInputNode),
        
        buildContainer(ListView(children: _children),),

        button,
      ],
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