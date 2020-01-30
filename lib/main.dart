import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';

import 'package:provider/provider.dart';

import './providers/map.dart';

import './screens/map_screen.dart';

void main() {

  debugPaintSizeEnabled = false;

  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
    ],
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
      ],
      child: MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MapScreen(),
    ),);
  }
}




