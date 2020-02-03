import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:provider/provider.dart';
import 'package:uturn/screens/map_screen.dart';

import '../providers/phone_auth.dart';
import '../models/user.dart';

class Profile extends StatefulWidget {
  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<Profile> {
  static User _userData = new User(phone: "", name: "", id: "");

  // bool _showGoogleMaps = false;
  final FocusNode myFocusNode = FocusNode();

  // 'profile' has to be inside the state — maybe when setState() is excuted,
  //  flutter checks whether a real change has occured to state's elements;
  //  if not, won't rebuild

  @override
  void initState() {
    super.initState();
    _userData = Provider.of<Auth>(context, listen: false).getProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          color: Theme.of(context).scaffoldBackgroundColor, child: _getbody()),
    );
  }

  List<Widget> _getProfile() {
    return [
      Padding(
        padding: EdgeInsets.only(top: 20.0),
        child: Stack(fit: StackFit.loose, children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                  width: 140.0,
                  height: 140.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: ExactAssetImage('assets/as.png'),
                      fit: BoxFit.cover,
                    ),
                  )),
            ],
          ),
        ]),
      ),
      Padding(
          padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0),
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                child: new Text(
                  'Personal Information',
                  style: Theme.of(context).textTheme.title,
                ),
              ),
            ],
          )),
      Padding(
          padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0),
          child: new Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              new Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  new Text(
                    'Name',
                    style: Theme.of(context).textTheme.subtitle,
                  ),
                ],
              ),
            ],
          )),
      Container(
        // height: 50,
        padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 2.0),
        child: new Text(
          _userData.name,
          style: Theme.of(context).textTheme.caption,
        ),
      ),
      Padding(
          padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0),
          child: new Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              new Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  new Text(
                    'Phone',
                    style: Theme.of(context).textTheme.subtitle,
                  ),
                ],
              ),
            ],
          )),
      Container(
        padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 2.0),
        child: new Text(
          _userData.phone,
          style: Theme.of(context).textTheme.caption,
        ),
      ),
      Padding(
          padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0),
          child: new Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              new Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  new Text(
                    'ID',
                    style: Theme.of(context).textTheme.subtitle,
                  ),
                ],
              ),
            ],
          )),
      Container(
        padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 2.0),
        child: new Text(
          _userData.id,
          style: Theme.of(context).textTheme.caption,
        ),
      ),
    ];
  }

  Widget _getbody() {
    return ListView(
      children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height * 0.1,
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(left: 10.0, top: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        IconButton(
                          padding: const EdgeInsets.all(0),
                          alignment: Alignment.center,
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => MapScreen(),
                              ),
                            );
                          },
                          color: Colors.white,
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 24.0,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 10.0),
                          child: Text('PROFILE',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  fontFamily: 'sans-serif-light',
                                  color:
                                      Theme.of(context).secondaryHeaderColor)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Padding(
                padding: EdgeInsets.only(bottom: 25.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: _getProfile(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    myFocusNode.dispose();
    super.dispose();
  }
}
