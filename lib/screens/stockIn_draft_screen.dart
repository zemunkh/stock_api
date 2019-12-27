import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import '../widgets/stockIn_draft_item.dart';
import '../styles/theme.dart' as Style;
import '../helper/file_manager.dart';
import '../widgets/main_drawer.dart';


class StockInDraftScreen extends StatefulWidget {
  static const routeName = '/draft';
  @override
  StockInDraftScreenState createState() => StockInDraftScreenState();
}

class StockInDraftScreenState extends State<StockInDraftScreen> {
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
          child: Container(
          child: new FutureBuilder(
            future: FileManager.getDraftBank(),
            builder: (context, snapshot){
              if(snapshot.connectionState == ConnectionState.done) {
                var myData = snapshot.data;
                return Container(
                  child: ListView.builder(
                    itemCount: myData == null ? 0: myData.length,
                    itemBuilder: (_, i) => Column(
                      children: [
                        StockInDraftItem(
                          myData[i],
                          i,
                        ),
                        Divider(),
                      ],
                    ),
                  ),
                );
              }
              else {
                return new Center(child:CircularProgressIndicator(),);
              }
            },
          ),
        ),
        ),
      ),
    );
  }
}
