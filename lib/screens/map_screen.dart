import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/map.dart';
import './bottom_map_screen.dart';
import '../components/map_pin_pill.dart';
import '../utils/map.dart';

import '../providers/phone_auth.dart';
import '../screens/auth_screen.dart';

class MapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: Consumer<MapProvider>(
              builder: (ctx, mapProvider, ch) => GoogleMap(
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  compassEnabled: false,
                  tiltGesturesEnabled: false,
                  markers: mapProvider.markers,
                  mapType: MapType.normal,
                  initialCameraPosition: mapProvider.initialCameraPosition,
                  onTap: (LatLng loc) {
                    mapProvider.setPinPillPosition(-100);
                  },
                  onMapCreated: (GoogleMapController controller) {
                    controller.setMapStyle(StyleUtil.mapStyles);
                    mapProvider.myController.complete(controller);
                    // my map has completed being created;
                    // i'm ready to show the pins on the map
                    mapProvider.showBusPinOnMap();
                  }),
            ),
          ),
          Positioned(
            top: 30,
            left: 15,
            child: IconButton(
              onPressed: () {
                Provider.of<Auth>(context, listen: false).signout();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => LoginPage(),
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
          ),
          MapPinPillComponent(),
          BottomButtons(),
        ],
      ),
    );
  }
}
