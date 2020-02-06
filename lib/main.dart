import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './providers/phone_auth.dart';
import './screens/auth_screen.dart';
import './screens/map_screen.dart';

void main() {
  debugPaintSizeEnabled = false;

  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
    ],
  );

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  isAuth() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();

    if (_prefs.containsKey('phone'))
      return true;
    else
      return false;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: FutureBuilder(
          future: isAuth(),
          builder: (ctx, authResultSnapshot) =>
              authResultSnapshot.data == true ? MapScreen() : LoginPage(),
        ),
      ),
    );
  }
}
