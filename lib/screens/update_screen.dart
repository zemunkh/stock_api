import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import '../widgets/main_drawer.dart';
import '../styles/theme.dart' as Style;

class UpdateStockScreen extends StatefulWidget {
  static const routeName = '/update';
  @override
  UpdateStockScreenState createState() => UpdateStockScreenState();
}

class UpdateStockScreenState extends State<UpdateStockScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();


  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  Future<Null> _updateHandler(BuildContext context) {
    print('I am clicked');
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

    final button = Padding(
      padding: EdgeInsets.all(10),
      child: MaterialButton(
        onPressed: () {
          _updateHandler(context);
        },
        child: Text(
          'Update StockIns',
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
        minWidth: 100,
        elevation: 2,
      )
    ); 

    return WillPopScope(
      onWillPop: _backButtonPressed,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Update StockIns'),
          backgroundColor: Style.Colors.mainAppBar,
        ),
        drawer: MainDrawer(),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text('Update Screen'),
                button,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
