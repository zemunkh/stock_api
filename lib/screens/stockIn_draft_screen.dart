import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  Future<bool> _backButtonPressed() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Exit the Stock App?"),
        actions: <Widget>[
          FlatButton(
            child: Text('Yes'),
            onPressed: () => SystemNavigator.pop(),
          ),
          FlatButton(
            child: Text('No'),
            onPressed: () => Navigator.of(context).pop(false),
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
          backgroundColor: Style.Colors.mainAppBar2,
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
