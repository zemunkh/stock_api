import 'package:flutter/material.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import '../screens/stockIn_draft_edit_screen.dart';
import '../screens/stockIn_draft_screen.dart';
import '../helper/file_manager.dart';



class StockInDraftItem extends StatelessWidget {
  final String draftName;
  final int index;

  StockInDraftItem(this.draftName, this.index);

  Future<Null> _deleteItem(BuildContext context, int index) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Are you sure to delete #${index + 1}?",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('Yes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF004B83),),),
            onPressed: () {
              FileManager.removeDraft('draft_other_$draftName');
              FileManager.removeDraft('draft_stockCode_$draftName');
              FileManager.removeDraft('draft_stockName_$draftName');
              FileManager.removeDraft('draft_lvl1uom_$draftName');
              FileManager.removeDraft('draft_lvl2uom_$draftName');
              FileManager.removeDraft('draft_lvl1uomCode_$draftName');
              FileManager.removeDraft('draft_lvl2uomCode_$draftName');
              FileManager.removeFromBank(index);
              print('Draft name: $draftName, index: $index');
              Navigator.of(context).pushReplacementNamed(StockInDraftScreen.routeName);
            },
          ),
          FlatButton(
            child: Text('No', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF004B83),)),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ));
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text('${index + 1}', style: TextStyle(fontWeight: FontWeight.bold),),
      title: Text(draftName),
      trailing: Container(
        width: 100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            IconButton(
              icon: Icon(EvaIcons.trash2Outline),
              onPressed: () => _deleteItem(context, index),
              color: Theme.of(context).errorColor,
            ),
          ],
        ),
      ),
      onTap: (){
        print('Tapped, Move to next screen');
        print('Draft name: $draftName');
        FileManager.setSelectedIndex(index);

        Navigator.of(context).pushReplacementNamed(StockInDraftEditScreen.routeName);
      },
    );
  }
}