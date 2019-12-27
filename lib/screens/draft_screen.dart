import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import '../styles/theme.dart' as Style;
import '../helper/file_manager.dart';
import '../widgets/main_drawer.dart';


class DraftScreen extends StatefulWidget {
  static const routeName = '/draft';
  @override
  DraftScreenState createState() => DraftScreenState();
}

class DraftScreenState extends State<DraftScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();


  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
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
    return WillPopScope(
      onWillPop: _backButtonPressed,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Drafts'),
          backgroundColor: Style.Colors.mainAppBar,
        ),
        drawer: MainDrawer(),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Center(
            child: Text('Draft Screen'),
          ),
        ),
      ),
    );
  }
}
