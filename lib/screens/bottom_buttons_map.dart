import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../providers/map.dart';

import '../components/custom_dialog.dart';

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
      child: Consumer<MapProvider>(
        builder: (ctx, mapProvider, ch) => (mapProvider.user == null ||
                mapProvider.user.identity == "driver")
            ? Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      color: Colors.deepPurple,
                      child: Center(
                        child: Text(
                          "Hello ${mapProvider.user == null ? " " : mapProvider.user.name.split(" ")[0]}!",
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : mapProvider.requestedRide
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
                                      mapProvider.setMyLocation(remove: true);

                                      showDialog(
                                        context: context,
                                        builder: (ctx) => CustomDialog(
                                          title: "Happy ride!",
                                          description: "Wish you a happy day",
                                          positiveButtonText: "Okay",
                                          negativeButtonText: "Back",
                                        ),
                                      );
                                    },
                                    color: Colors.deepPurple,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(0)),
                                    ),
                                    child: Text(
                                      "PICKED UP",
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
                                      mapProvider.setMyLocation(remove: true);
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
                            mapProvider.setMyLocation(remove: false);
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
    );
  }
}
