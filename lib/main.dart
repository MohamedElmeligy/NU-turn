import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:custom_splash/custom_splash.dart';

import 'package:provider/provider.dart';
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

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: CustomSplash(
      imagePath: 'assets/Logo.png',
      backGroundColor: Colors.white,
      animationEffect: 'fade-in',
      logoSize: 180,
      home: MyApp(),
      customFunction: () {},
      duration: 3000,
      type: CustomSplashType.StaticDuration,
    ),
  ));
}

class MyApp extends StatelessWidget {
  Future<bool> isAuth() async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey('phone')) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Auth>(
          create: (ctx) => Auth(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: FutureBuilder(
            future: isAuth(),
            builder: (ctx, auth) =>
                auth.data == true ? MapScreen() : LoginPage()),
      ),
    );
  }
}
