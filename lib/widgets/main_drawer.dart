import 'package:flutter/material.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:retail_api/screens/import_stocks_screen.dart';
import '../screens/stockIn_draft_screen.dart';
import '../screens/home_screen.dart';
import '../screens/settings_screen.dart';


class MainDrawer extends StatelessWidget {

  Widget buildListTile(String title, IconData icon, Function tabHandler) {
    return ListTile(
      leading: Icon(
        icon,
        size: 26,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'RobotoCondensed',
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: tabHandler,
    );
  }


  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: 120,
              width: double.infinity,
              padding: EdgeInsets.all(20),
              alignment: Alignment.centerLeft,
              color: Theme.of(context).accentColor,
              child: Text(
                'Menu',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 30,
                  color: Colors.grey[700],
                ),
              ),
            ),
            SizedBox(height: 20,),
            buildListTile(
              'New Stock In', 
              EvaIcons.home,
              () {
                Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
              }
            ),

            new Divider(height: 15.0,color: Colors.black87,),
            
            SizedBox(height:  20),

            buildListTile(
              'Drafts', 
              EvaIcons.carOutline,
              () {
                Navigator.of(context).pushReplacementNamed(StockInDraftScreen.routeName);
              }
            ),          

            buildListTile(
              'Settings', 
              EvaIcons.settings2Outline,
              () {
                Navigator.of(context).pushReplacementNamed(SettingScreen.routeName);
              }
            ),

            new Divider(height: 15.0,color: Colors.black87,),

            buildListTile(
              'Update Stocks', 
              EvaIcons.syncOutline,
              () {
                Navigator.of(context).pushReplacementNamed(ImportStocksScreen.routeName);
              }  
            )
          ],
        ),
      ),
    );
  }
}
