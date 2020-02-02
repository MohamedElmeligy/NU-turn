import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
                      Text(
                        mapProvider.currentlySelectedPin.name ?? "",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 5),
                      /* Text(
                        mapProvider.currentlySelectedPin.phone ?? "",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ), */
                      if (mapProvider.currentlySelectedPin.id != "")
                        Text(
                          'ID: ${mapProvider.currentlySelectedPin.id}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (mapProvider.currentlySelectedPin.pinPath != "")
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  child: IconButton(
                    onPressed: () async {
                      String url =
                          'tel:${mapProvider.currentlySelectedPin.phone}';
                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        throw 'Could not launch $url';
                      }
                    },
                    padding: const EdgeInsets.all(0),
                    icon: Icon(
                      Icons.call,
                      size: 36,
                      color: Colors.deepPurple,
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
