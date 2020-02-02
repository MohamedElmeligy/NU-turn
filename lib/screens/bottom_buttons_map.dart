import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../providers/map.dart';
import '../providers/phone_auth.dart';

import '../models/user.dart';

class BottomButtons extends StatelessWidget {
  const BottomButtons({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      bottom: 0,
      left: 0,
      right: 0,
      height: 60,
      duration: Duration(milliseconds: 1500),
      curve: Curves.easeInOutCubic,
      child: Selector<Auth, User>(
        selector: (ctx, auth) => auth.user,
        builder: (ctx, user, ch) => Consumer<MapProvider>(
          builder: (ctx, mapProvider, ch) => mapProvider.requestedRide
              ? Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Positioned(
                        left: 0,
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                height: 60,
                                child: RaisedButton(
                                  onPressed: () {
                                    mapProvider.setMyLocation(
                                        remove: true, user: user);
                                  },
                                  color: Colors.deepPurple,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(0)),
                                  ),
                                  child: Text(
                                    "RIDE",
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 60,
                                child: RaisedButton(
                                  onPressed: () {
                                    mapProvider.setMyLocation(
                                        remove: true, user: user);
                                  },
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(0)),
                                  ),
                                  child: Text(
                                    "CANCEL",
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: Colors.deepPurple,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )),
                    if (mapProvider.addingMyRequest)
                      Container(
                        color: Color(0x55DDDDDD),
                      ),
                    if (mapProvider.addingMyRequest)
                      CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                      ),
                  ],
                )
              : Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: RaisedButton(
                        onPressed: () {
                          mapProvider.setMyLocation(remove: false, user: user);
                        },
                        color: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(0)),
                        ),
                        child: Text(
                          "NEED A RIDE",
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    if (mapProvider.addingMyRequest)
                      Container(
                        color: Color(0x55DDDDDD),
                      ),
                    if (mapProvider.addingMyRequest)
                      CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}
