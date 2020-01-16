import 'package:flutter/material.dart';
import './screens/import_stocks_screen.dart';
import './screens/settings_screen.dart';
import './screens/stockIn_draft_edit_screen.dart';
import './screens/stockIn_draft_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './screens/activation_screen.dart';
import './screens/home_screen.dart';

bool activated = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    activated = await _read();
    runApp(MyApp());
  } catch(error) {
    print('Activation Status error: $error');
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mugs Stock API',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        accentColor: Colors.amber,
        primarySwatch: Colors.blue,
        textTheme: ThemeData.light().textTheme.copyWith(
          title: TextStyle(
            fontFamily: 'HelveticaNeue',
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          button: TextStyle(
            color: Colors.white,
          ),
        ),
        fontFamily: 'HelveticaNeue',
        appBarTheme: AppBarTheme(
          textTheme: ThemeData.light().textTheme.copyWith(
            title: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      // home: HomeScreen(),
      routes: {
        '/': (ctx) => activated ? HomeScreen() : ActivationScreen(),
        '/main': (ctx) => HomeScreen(),
        StockInDraftScreen.routeName: (ctx) => StockInDraftScreen(),
        SettingScreen.routeName: (ctx) => SettingScreen(),
        ImportStocksScreen.routeName: (ctx) => ImportStocksScreen(),
        StockInDraftEditScreen.routeName: (ctx) => StockInDraftEditScreen(),
      },
      onGenerateRoute: (settings) {
        print(settings.arguments);
        return null;
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (ctx) => HomeScreen(),
        );
      },
    );
  }

}

_read() async {
  final prefs = await SharedPreferences.getInstance();
  final key = 'my_activation_status_api';
  final status = prefs.getBool(key) ?? false;
  print('Activation Status: $status');
  // activated = status;
  return status;
}