import 'dart:math';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import './auth_screen.dart';
import '../providers/map.dart';

class UpperButtons extends StatelessWidget {
  const UpperButtons({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 40,
      left: 15,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          IconButton(
            padding: const EdgeInsets.all(0),
            alignment: Alignment.center,
            onPressed: () {
              Provider.of<MapProvider>(context, listen: false).signout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => LoginPage(),
                ),
              );
            },
            color: Colors.transparent,
            icon: Transform.rotate(
              angle: pi,
              child: Icon(
                Icons.exit_to_app,
                textDirection: TextDirection.ltr,
                color: Colors.deepPurple,
                size: 36.0,
              ),
            ),
          ),
          Text(
            'Log out',
            style: TextStyle(
              fontSize: 12,
              color: Colors.deepPurple,
            ),
          ),
        ],
      ),
    );
  }
}
