import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../helper/database_helper.dart';
import '../helper/file_manager.dart';

class Transaction extends StatefulWidget {
  @override
  _TransactionState createState() => _TransactionState();
}

class _TransactionState extends State<Transaction> {
  final dbHelper = DatabaseHelper.instance;
  
  List<TextEditingController> _stockInputControllers = new List();
  List<TextEditingController> _lvl1InputControllers = new List();
  List<TextEditingController> _lvl2InputControllers = new List();

  List<FocusNode> _stockInputNodes = new List();
  List<FocusNode> _lvl1InputNodes = new List();
  List<FocusNode> _lvl2InputNodes = new List();

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

    List<Map> stockData = await dbHelper.queryAllRows();

    stockData.forEach((row){
      if(row["stockCode"] == stockCode) {
        print('ID: ${row["id"]}');
        int id = row["id"];
        _stockNames[index] = (row["stockName"]);
        _baseUOMs[index] = (row["baseUOM"]);

        // _lvl1InputControllers[index].text = row["baseUOM"];
        
        // this will build baseUOM lvl1, lvl2 widgets
      }
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
            },
          ),
          FlatButton(
            child: Text('No'),
            onPressed: () {
              print('No clicked');
            },
          ),
        ],
      )
    );
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

    setState(() {
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
            setState(() {
            _baseUOMs.removeAt(index);
            _stockNames.removeAt(index);
            _stockInputControllers.removeAt(index);
            _lvl1InputControllers.removeAt(index);
            _lvl2InputControllers.removeAt(index);

            _stockInputNodes.removeAt(index);
            _lvl1InputNodes.removeAt(index);
            _lvl2InputNodes.removeAt(index);
          });
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
                    hintText: _baseUOMs[index],
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
                    hintText:_baseUOMs[index],
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
            color: Colors.grey[850],
            size: 50,
          ),
          // shape: StadiumBorder(),
          // color: Colors.blue,
          splashColor: Colors.teal,
          // height: 40,
          // minWidth: 40,
          elevation: 2,
        ),
      ),
    );

    final postButton = Center(
      child: Padding(
        padding: EdgeInsets.all(10),
        child: MaterialButton(
          onPressed: () {
            // gather all the information and post data to db by api lib.
            _postTransaction();

          },
          child: Icon(
            EvaIcons.uploadOutline,
            color: Colors.white,
            size: 40,
          ),
          shape: StadiumBorder(),
          color: Colors.teal[300],
          splashColor: Colors.green[50],
          height: 50,
          minWidth: 250,
          elevation: 2,
        ),
      ),
    );

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
        postButton,
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