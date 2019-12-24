import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import '../widgets/main_drawer.dart';
import '../styles/theme.dart' as Style;

class SavedRecordScreen extends StatelessWidget {
  static const routeName = '/record';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Record Page'),
        backgroundColor: Style.Colors.mainAppBar,
      ),
      drawer: MainDrawer(),
      body: Center(
        child: Text('Hi Record!'),
      ),
    );
  }
}