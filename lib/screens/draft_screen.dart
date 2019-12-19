import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helper/file_manager.dart';
import '../widgets/main_drawer.dart';


class SettingScreen extends StatefulWidget {
  static const routeName = '/settings';
  @override
  SettingScreenState createState() => SettingScreenState();
}

class SettingScreenState extends State<SettingScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _deviceController = TextEditingController();
  final _usernameController = TextEditingController();
  
  FocusNode _deviceNode = FocusNode();
  FocusNode _usernameNode = FocusNode();

  bool lockEn = true;



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

  Future<Null> setInitialValue() async {
    _usernameController.text = await FileManager.readProfile('user_name');
    _deviceController.text = await FileManager.readProfile('device_name');
  }

  @override
  void dispose() {
    super.dispose();
    _deviceController.dispose();
    _usernameController.dispose();
  }

  @override
  void initState() {
    super.initState();
    setInitialValue();
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

    Widget _mainInput(String header, TextEditingController _mainController, FocusNode _mainNode) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            flex: 4,
            child: Text(
              '$header:',
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
                        hintText: header,
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
                            _clearTextController(context, _mainController, _mainNode);
                          },
                        ),
                      ),
                      autofocus: false,
                      controller: _mainController,
                      validator: (String value) {
                        if(value.isEmpty) {
                          return 'Enter Scan Number';
                        } else if(int.parse(value) >= 9){
                          return 'Too much. Suggestion: 1-8';
                        }
                      },
                      focusNode: _mainNode,
                      onTap: () {
                        _focusNode(context, _mainNode);
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


    Widget _saveButton(BuildContext context) {
      return Padding(
        padding: EdgeInsets.all(10),
        child: MaterialButton(
          onPressed: () {
            print('You pressed Save!');
            String dname = _deviceController.text;
            String uname = _usernameController.text;
            if(dname != '' && uname != '') {
              FileManager.saveProfile('device_name', dname).then((_){
                FileManager.saveProfile('user_name',uname);
              });
              print('Saving now!');
              _scaffoldKey.currentState.showSnackBar(SnackBar(
                content: new Text("User data is saved successfully!", textAlign: TextAlign.center,),
                duration: const Duration(milliseconds: 2000)
              ));
            }
            else {
              print('Dismissing it now!');
              // Input values are empty
              _scaffoldKey.currentState.showSnackBar(SnackBar(
                content: new Text("Can't be saved!", textAlign: TextAlign.center,),
                duration: const Duration(milliseconds: 2000)
              ));
            }
            // save operation by shared preference
          },
          child: Text(
            'Save',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'QuickSand',
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          shape: StadiumBorder(),
          color: Colors.teal[400],
          splashColor: Colors.blue[100],
          height: 50,
          minWidth: 200,
          elevation: 2,
        )
      );
    }  
    
    
    return WillPopScope(
      onWillPop: _backButtonPressed,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Settings'),
        ),
        drawer: MainDrawer(),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Container(
            child: Column(
              children: <Widget>[
                
                _mainInput('Device Name',_deviceController, _deviceNode),
                _mainInput('Username',_usernameController, _usernameNode),
                SizedBox(height: 15,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: _saveButton(context),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    
  }
}
