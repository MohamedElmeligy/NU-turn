import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';

import 'package:provider/provider.dart';
import 'package:uturn/screens/map_screen.dart';

import './providers/phone_auth.dart';

import './screens/auth_screen.dart';

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
        ChangeNotifierProvider<Auth>(
          create: (ctx) => Auth(),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(
            scaffoldBackgroundColor: Colors.deepPurple,
            secondaryHeaderColor: Colors.white,
            textTheme: TextTheme(
              title: TextStyle(color: Colors.white, fontSize: 28),
              subtitle: TextStyle(color: Colors.white, fontSize: 22),
              caption: TextStyle(color: Colors.white, fontSize: 18),
            )),
        debugShowCheckedModeBanner: false,
        // home: LoginPage(),
        home: Consumer<Auth>(
          builder: (ctx, auth, ch) {
            return FutureBuilder(
                future: auth.isAuth(),
                builder: (ctx, auth) =>
                    auth.connectionState == ConnectionState.waiting
                        ? CircularProgressIndicator()
                        : auth.data == true ? MapScreen() : LoginPage());
          },
        ),
      ),
    );
  }
}
