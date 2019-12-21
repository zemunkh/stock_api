import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';

class SavedRecordScreen extends StatelessWidget {
  static const routeName = '/record';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Record Page'),
        leading: IconButton(
          icon: Icon(
            EvaIcons.arrowBack,
          ),
          color: Colors.white,
          onPressed: (){
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: Text('Hi Record!'),
      ),
    );
  }
}