import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import './providers/map.dart';
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
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MapProvider>(
          create: (ctx) => MapProvider(),
        ),
        ChangeNotifierProvider<Auth>(
          create: (ctx) => Auth(),
        ),
      ],
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Consumer<Auth>(
            builder: (ctx, auth, ch) {
              return FutureBuilder(
                  future: auth.getIsLoggedIn(),
                  builder: (ctx, result) =>
                      result.data == true ? MapScreen() : LoginPage());
            },
          )),
    );
  }
}
