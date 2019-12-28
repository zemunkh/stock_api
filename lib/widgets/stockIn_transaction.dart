import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
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

  List<String> _baseUOMs = [];
  List<String> _stockNames = [];

  // Dropdown menu variables
  List<String> _descriptions = [];
  List<String> _descripts = [];
  String dropdownValue = '';
  String buffer = '';
  String trueVal = '';
  // <String>['One from the world, you know it', 'Two', 'Free', 'Four']

  Future<Null> _searchStockCode(int index, String stockCode) async {
    bool isEmpty = false;
    List<Map> stockData = await dbHelper.queryAllRows();

    stockData.forEach((row){
      if(row["stockCode"] == stockCode) {
        print('ID: ${row["id"]}');
        _stockNames[index] = (row["stockName"]);
        _baseUOMs[index] = (row["baseUOM"]);

        isEmpty = isEmpty || true;
        print('I got this :)');
        // _lvl1InputControllers[index].text = row["baseUOM"];
        
        // this will build baseUOM lvl1, lvl2 widgets
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


  Future<bool> _postTransaction() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Do you want to upload the transactions?"),
        actions: <Widget>[
          FlatButton(
            child: Text('Yes'),
            onPressed: () {
              print('Yes clicked');
              Navigator.of(context).pop();
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
  }

  Future<Null> _saveTheDraft(DateTime createdDate) async {
    int len = _stockInputControllers.length;

    List<String> _stockCodeList = [];
    List<String> _stockNameList = [];
    List<String> _lvl1uomList = [];
    List<String> _lvl2uomList = [];
    List<String> _otherList = [];

    for(int i = 0; i < len; i++) {
      _stockCodeList.add(_stockInputControllers[i].text);
      _stockNameList.add(_stockNames[i]);
      _lvl1uomList.add(_lvl1InputControllers[i].text);
      _lvl2uomList.add(_lvl2InputControllers[i].text);
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
    FileManager.saveDraft('draft_lvl1uomList_$index', _lvl1uomList);
    FileManager.saveDraft('draft_lvl2uomList_$index', _lvl2uomList);
    FileManager.saveDraft('draft_other_$index', _otherList);
    FileManager.saveDraft('draft_baseUoms_$index', _baseUOMs);
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
                _baseUOMs.removeAt(index);
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

    setState(() {
      if(numbering < 10) {
        trxNumber = 'SIN${DateFormat("yyMMdd").format(currentDate)}/00$numbering';
      } else if(numbering < 100 && numbering >= 10) {
        trxNumber = 'SIN${DateFormat("yyMMdd").format(currentDate)}/0$numbering';
      } else {
        trxNumber = 'SIN${DateFormat("yyMMdd").format(currentDate)}/$numbering';
      }

      _baseUOMs.add('Unit');
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
                height: 40,
                child: TextFormField(
                    style: TextStyle(
                    fontSize: 12, 
                    color: Color(0xFF004B83),
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration.collapsed(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: '  lvl1: ${_baseUOMs[index]}',
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
              _baseUOMs[index],
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
                height: 40,
                child: TextFormField(
                  style: TextStyle(
                    fontSize: 12, 
                    color: Color(0xFF004B83),
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration.collapsed(
                    filled: true,
                    fillColor: Colors.white,
                    hintText:'  lvl2: ${_baseUOMs[index]}',
                    hintStyle: TextStyle(
                      color: Color(0xFF004B83), 
                      fontWeight: FontWeight.w200,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
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
              _baseUOMs[index],
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
              _baseUOMs.add('');
              _stockNames.add('');
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
            _postTransaction();

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

    final transaction = Column(
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