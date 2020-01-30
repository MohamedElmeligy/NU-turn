import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/map.dart';
import '../components/map_pin_pill.dart';
import '../utils/map.dart';

class MapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<MapProvider>(
        builder: (ctx, mapProvider, ch) => Stack(
          children: <Widget>[
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              right: 0,
              child: GoogleMap(
                  myLocationEnabled: true,
                  compassEnabled: true,
                  tiltGesturesEnabled: false,
                  markers: mapProvider.markers,
                  mapType: MapType.normal,
                  initialCameraPosition: mapProvider.initialCameraPosition,
                  onTap: (LatLng loc) {
                    mapProvider.pinPillPosition = -100;
                  },
                  onMapCreated: (GoogleMapController controller) {
                    controller.setMapStyle(StyleUtil.mapStyles);
                    mapProvider.myController.complete(controller);
                    // my map has completed being created;
                    // i'm ready to show the pins on the map
                    mapProvider.showBusPinOnMap();
                  }),
            ),
            MapPinPillComponent(
              pinPillPosition: mapProvider.pinPillPosition,
              currentlySelectedPin: mapProvider.currentlySelectedPin,
            )
          ],
        ),
      ),
    );
  }
}
