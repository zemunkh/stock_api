import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Transaction extends StatefulWidget {
  @override
  _TransactionState createState() => _TransactionState();
}

class _TransactionState extends State<Transaction> {

  final _stockInputController = TextEditingController();
  FocusNode _stockInputNode = FocusNode();

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

  @override
  void dispose() {
    super.dispose();
    _stockInputController.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DateTime createdDate = DateTime.now();
    String dropdownValue = 'One';

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
            child: Stack(
              alignment: Alignment(1.0, 1.0),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Center(
                    child: TextFormField(
                      style: TextStyle(
                        fontSize: 16, 
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
                            size: 32,
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
              ],
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
                  },
                  items: <String>['One', 'Two', 'Free', 'Four'].map<DropdownMenuItem<String>>((String value) {
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

    Widget dateTime(String time) {
      return Text(
        time,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'QuickSand',
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.black,
        ),
      );
    }

    final transaction = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        dateTime(DateFormat("yyyy/MM/dd HH:mm:ss").format(createdDate)),
        // descriptionMenu,
        // stockParameters,
        _descriptionMenu(context, 'Description:'),
        new Divider(height: 20.0, color: Colors.black87,),

        _stockInput(_stockInputController, _stockInputNode),

        Text('Hello'),
        Text('Hello'),
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