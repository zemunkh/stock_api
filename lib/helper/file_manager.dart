import 'package:shared_preferences/shared_preferences.dart';



class FileManager {
  static get context => null;

// ================= Draft data Handling Methods ================== //

  static Future<Null> saveDraft(String key, List<String> list) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(key, list);
  }


  static Future<List> readDraft(String key) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> draftedList = prefs.getStringList(key);

    return draftedList;
  }

  static Future<Null> removeDraft(String key) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }

  // ================ User Profile Saving Methods ================== //

  static Future<Null> saveProfile(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  static Future<String> readProfile(String key) async {
    final prefs = await SharedPreferences.getInstance();
    String profile = prefs.getString(key);
    if(profile == null) {
      return '';
    }
    return profile;
  }


  static Future<List> readDescriptions() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> descripts = prefs.getStringList('stock_descriptions');
    print('Descriptions List: $descripts');
    if(descripts == null) {
      descripts = ['1. ', '2. ', '3. ', '4. ', '5. ', '6. ', '7. ', '8. '];
      return descripts;
    } else {
      return descripts;
    }
  }
  // Think again.
  static Future<Null> setDescriptionList(List<String> descriptions) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> descripts = prefs.getStringList('stock_descriptions');
    if(descripts == null || descripts.isEmpty) {
      descripts = descriptions;
      print('Initializing the descriptions');
      prefs.setStringList('stock_descriptions', descripts);
    } else {
      print('Overwriting the descriptions');
      prefs.setStringList('stock_descriptions', descriptions);
    }
    print('Descriptions List: $descriptions');
    return null;
  }

  static Future<Null> setStockLength(int len) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('stock_length', len);
    return null;
  }
  static Future<int> getStockLength() async {
    final prefs = await SharedPreferences.getInstance();
    int len = prefs.getInt('stock_length');
    if(len == null) {
      return 0;
    }
    return len;
  }

// Transaction Numbering Date Saving 

  static Future<Null> setTrxDate(String value) async {
    final prefs = await SharedPreferences.getInstance();
    String key = 'trx_date';
    prefs.setString(key, value);
  }

  static Future<String> getTrxDate() async {
    final prefs = await SharedPreferences.getInstance();
    String key = 'trx_date';
    String trxDate = prefs.getString(key);
    if(trxDate == null) {
      return ' ';
    }
    return trxDate;
  }


  static Future<Null> setTrxNumbering(int number) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('trx_numbering', number);
    return null;
  }
  // Set and get Transaction numbering by system
  static Future<int> getTrxNumbering() async {
    final prefs = await SharedPreferences.getInstance();
    int number = prefs.getInt('trx_numbering');
    print("Number: $number \r\n");
    if(number == null || number == 0) {
      return 1;
    }
    return number;
  }

  static Future<Null> setSelectedIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('draft_selected', index);
    return null;
  }
  static Future<int> getSelectedIndex() async {
    final prefs = await SharedPreferences.getInstance();
    int index = prefs.getInt('draft_selected');
    return index;
  }

  static Future<Null> saveDraftBank(String draftName) async {
    final prefs = await SharedPreferences.getInstance();
    String key = 'draft_trx_list';
    List<String> drafts = prefs.getStringList(key);
    if(drafts == null || drafts.isEmpty) {
      drafts = [draftName];
      prefs.setStringList(key, drafts);
    } else {
      if(drafts[drafts.length - 1] != draftName) {
        drafts.add(draftName);
        prefs.setStringList(key, drafts);
      }
    }
    print('Draft Name List: $drafts');
    return null;
  }

  static Future<List> getDraftBank() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'draft_trx_list';
    List<String> drafts = prefs.getStringList(key);
    if(drafts == null) {
      drafts = [];
    }
    print('Draft Bank: $drafts');
    return drafts;
  }

  static Future<Null> removeFromBank(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'draft_trx_list';
    List<String> drafts = prefs.getStringList(key);
    if(prefs != null) {
      drafts.removeAt(index);
      prefs.setStringList(key, drafts);
    }
    print('Draft List: $drafts');
  }

}
