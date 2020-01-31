import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../providers/map.dart';

class MapPinPillComponent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    MapProvider mapProvider = Provider.of<MapProvider>(context);
    return AnimatedPositioned(
      bottom: mapProvider.pinPillPosition,
      right: 0,
      left: 0,
      duration: Duration(milliseconds: 200),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: EdgeInsets.all(20),
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(50)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                blurRadius: 20,
                offset: Offset.zero,
                color: Colors.grey.withOpacity(0.5),
              )
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (mapProvider.currentlySelectedPin.avatarPath != "")
                Container(
                  width: 50,
                  height: 50,
                  margin: EdgeInsets.only(left: 10),
                  child: ClipOval(
                    child: Image.asset(
                      mapProvider.currentlySelectedPin.avatarPath,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(mapProvider.currentlySelectedPin.locationName,
                          style: TextStyle(
                              color:
                                  mapProvider.currentlySelectedPin.labelColor)),
                      Text(
                          'Latitude: ${mapProvider.currentlySelectedPin.location.latitude.toString()}',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text(
                          'Longitude: ${mapProvider.currentlySelectedPin.location.longitude.toString()}',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
              if (mapProvider.currentlySelectedPin.pinPath != "")
                Padding(
                  padding: EdgeInsets.all(15),
                  child: Image.asset(
                    mapProvider.currentlySelectedPin.pinPath,
                    width: 50,
                    height: 50,
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
