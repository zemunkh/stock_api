import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import '../widgets/main_drawer.dart';
import '../helper/file_manager.dart';
import '../styles/theme.dart' as Style;




class SettingScreen extends StatefulWidget {
  static const routeName = '/settings';
  @override
  SettingScreenState createState() => SettingScreenState();
}

class SettingScreenState extends State<SettingScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _deviceController = TextEditingController();
  final _usernameController = TextEditingController();
  final _ipAddressController = TextEditingController();
  final _portNumController = TextEditingController();
  final _companyController = TextEditingController();
  
  FocusNode _deviceNode = FocusNode();
  FocusNode _usernameNode = FocusNode();
  FocusNode _ipNode = FocusNode();
  FocusNode _portNode = FocusNode();
  FocusNode _compNode = FocusNode();

  List<TextEditingController> _descriptionControllers = new List();
  List<FocusNode> _descriptionFocusNodes = new List();

  List<String> _descriptions = [];
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
    _descriptions = await FileManager.readDescriptions();
    List<String> parsed = [];
    for(int i = 0; i < 8; i++) {
      setState(() {
        _descriptionControllers.add(new TextEditingController());
        _descriptionFocusNodes.add(new FocusNode());
      });
    }
    if(_descriptions.isEmpty || _descriptions == null) {
      for(int i = 0; i < _descriptionControllers.length; i++) {
        setState(() {
          _descriptionControllers[i].text = 'Unknown';
        });
      }
    } else {
      for(int i = 0; i < _descriptionControllers.length; i++) {
        setState(() {
          if(_descriptions[i] != '') {
            parsed = _descriptions[i].split('. ');
            _descriptionControllers[i].text = parsed[1]; 
          } else {
            _descriptionControllers[i].text = 'Unknown'; 
          }
        });
      }
    }
    // Initializing 8 types of description input models
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
            child: Padding(
              padding: const EdgeInsets.all(2.0),
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
                        size: 24,
                      ),
                      onPressed: () {
                        _clearTextController(context, _mainController, _mainNode);
                      },
                    ),
                  ),
                  autofocus: false,
                  controller: _mainController,
                  focusNode: _mainNode,
                  onTap: () {
                    _focusNode(context, _mainNode);
                  },
                ),
              ),
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
            List<String> _descripts = [];
            String dname = _deviceController.text;
            String uname = _usernameController.text;
            String ip = _ipAddressController.text;
            String port = _portNumController.text;
            String company = _companyController.text;
            if(dname != '' && uname != '') {
              FileManager.saveProfile('device_name', dname).then((_){
                FileManager.saveProfile('user_name',uname);
                FileManager.saveProfile('ip_address', ip);
                FileManager.saveProfile('port_number', port);
                FileManager.saveProfile('compnay_name', company);
              });
              print('Saving now!');
              int i = 0;
              for (TextEditingController dController in _descriptionControllers) {
                i++;
                if(dController.text != '' || dController.text != null) {
                  _descripts.add('$i. ${dController.text}');
                } else {
                  _descripts.add('$i. Unknown');
                }
                print('HOho: ${dController.text}'); 
              }
              FileManager.setDescriptionList(_descripts).then((_){
                _scaffoldKey.currentState.showSnackBar(SnackBar(
                  content: new Text("User data is saved successfully!", textAlign: TextAlign.center,),
                  duration: const Duration(milliseconds: 2000)
                ));
              });
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
    
    Widget _descriptionInput(BuildContext context, TextEditingController _controller, FocusNode _focusNode, index) {
      return Padding(
        padding: const EdgeInsets.all(2.0),
        child: Container(
          height: 25,
          child: TextFormField(
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF004B83),
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration.collapsed(
              filled: true,
              fillColor: Colors.white,
              hintText: 'Description',
              hintStyle: TextStyle(
                color: Color(0xFF004B83),
                fontSize: 14,
                fontWeight: FontWeight.w300,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
            autofocus: true,
            controller: _controller,
            focusNode: _focusNode,
            onTap: () {
              _clearTextController(context, _controller, _focusNode);
            },
          ),
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

    Widget _descriptionInputList(BuildContext context) {
      return ListView.builder(
        itemCount: _descriptionControllers?.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            padding: const EdgeInsets.all(4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Description #${index + 1}:'),
                _descriptionInput(context, _descriptionControllers[index], _descriptionFocusNodes[index], index),
              ],
            ),
          );
        },
      );
    }

    final transaction = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _mainInput('Device Name',_deviceController, _deviceNode),
        _mainInput('Username',_usernameController, _usernameNode),
        _mainInput('IP address',_ipAddressController, _ipNode),
        _mainInput('Port Num', _portNumController, _portNode),
        _mainInput('Company Name', _companyController, _compNode),
        SizedBox(height: 15,),

        buildContainer(_descriptionInputList(context)),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
             _saveButton(context),
          ],
        ),

      ],
    );

    return WillPopScope(
      onWillPop: _backButtonPressed,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Settings'),
          backgroundColor: Style.Colors.mainAppBar,
        ),
        drawer: MainDrawer(),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: LayoutBuilder(
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
            ),
          ),
        ),
      ),
    );
    
  }
}
