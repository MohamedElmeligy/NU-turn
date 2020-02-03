import 'dart:math';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import './profile_screen.dart';
import './auth_screen.dart';
import '../providers/phone_auth.dart';

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
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => Profile(),
                ),
              );
            },
            color: Colors.transparent,
            icon: Icon(
              Icons.person,
              color: Colors.deepPurple,
              size: 36.0,
            ),
          ),
          Text(
            'Profile',
            style: TextStyle(
              fontSize: 12,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 12),
          IconButton(
            padding: const EdgeInsets.all(0),
            alignment: Alignment.center,
            onPressed: () {
              Provider.of<Auth>(context, listen: false).signout();
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
