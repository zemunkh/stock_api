import 'package:flutter/material.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:retail_api/widgets/stock_update_items.dart';

import '../widgets/main_drawer.dart';
import '../styles/theme.dart' as Style;

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override 
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Style.Colors.background,
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.0),
        child: AppBar(
          elevation: 2.0,
          backgroundColor: Color(0xFFFF9500),
          leading: IconButton(
            icon: Icon(
              EvaIcons.menu2Outline,
            ),
            color: Colors.white,
            onPressed: () {
              _scaffoldKey.currentState.openDrawer();
            },
          ),
          title: new Text(
            'Mugs Stock Control',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                EvaIcons.infoOutline,
              ),
              color: Colors.white,
              onPressed: () {},
            )
          ],
        ),
      ),
      drawer: MainDrawer(),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Transaction(),
      ),
    );
  }
}
