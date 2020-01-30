import 'dart:async';

import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import '../models/pin_pill_info.dart';

class MapProvider with ChangeNotifier {
  static const double CAMERA_ZOOM = 16;
  static const double CAMERA_TILT = 80;
  static const double CAMERA_BEARING = 30;
  static const LatLng MY_LOCATION = LatLng(30.025994, 31.022815);
  static const LatLng BUS_LOCATION = LatLng(30.0432003, 31.1889163);

  Completer<GoogleMapController> myController = Completer();

  Map<String, Marker> _markers = Map<String, Marker>();

// Google API Key
  String googleAPIKey = 'AIzaSyCkNE0xD2eBlnda-PI6jOjrBRiK85BM0Do';

// for my custom marker pins
  BitmapDescriptor myLocationIcon;
  BitmapDescriptor busLocationIcon;

  LatLng myPosition;

// the bus's initial location and current location
// as it moves
  LocationData busLocationData;

// wrapper around the location API
  Location busLocation = Location();

  CameraPosition initialCameraPosition;

  double _pinPillPosition = -60;
  PinInformation currentlySelectedPin = PinInformation(
      pinPath: '',
      avatarPath: '',
      location: LatLng(0, 0),
      locationName: '',
      labelColor: Colors.grey);
  PinInformation myPinInfo;
  PinInformation busPinInfo;

// Defualt construction;
  MapProvider() {
    // subscribe to changes in the bus's location
    // by "listening" to the location's onLocationChanged event
    busLocation.onLocationChanged().listen((LocationData cLoc) {
      // cLoc contains the lat and long of the
      // current bus's position in real time,
      // so we're holding on to it
      busLocationData = cLoc;
      updatePinsOnMap();
    });

    initialCameraPosition = CameraPosition(
      zoom: CAMERA_ZOOM,
      tilt: CAMERA_TILT,
      bearing: CAMERA_BEARING,
      target: BUS_LOCATION,
    );

    // set custom marker pins
    setMyAndBusIcons();

    // set the initial location
    setInitialBusLocation();
  }

  Set<Marker> get markers => (_markers.values.toSet());
  double get pinPillPosition => _pinPillPosition;

  void setMyLocation(LatLng myLocation) {
    myPosition = myLocation;
    myPosition == null
        ? _markers.remove('myPin')
        : _markers.update(
            'myPin',
            (marker) => Marker(
              markerId: MarkerId('myPin'),
              position: myPosition,
              onTap: () {
                currentlySelectedPin = myPinInfo;
                setPinPillPosition(60);
              },
              icon: myLocationIcon,
            ),
            ifAbsent: () => Marker(
              markerId: MarkerId('myPin'),
              position: myPosition,
              onTap: () {
                currentlySelectedPin = myPinInfo;
                setPinPillPosition(60);
              },
              icon: myLocationIcon,
            ),
          );
    notifyListeners();
  }

  void setPinPillPosition(double pos) {
    _pinPillPosition = pos;
    notifyListeners();
  }

  void setMyAndBusIcons() async {
    myLocationIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      'assets/driving_pin.png',
    );

    busLocationIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      'assets/destination_map_marker.png',
    );
  }

  void setInitialBusLocation() async {
    // hard-coded destination for this example
    busLocationData = await busLocation.getLocation();
  }

  void showBusPinOnMap() {
    // get a LatLng out of the LocationData object

    LatLng busPosition;

    if (busLocationData != null) {
      busPosition = LatLng(busLocationData.latitude, busLocationData.longitude);
    } else {
      busPosition = BUS_LOCATION;
    }

    myPinInfo = PinInformation(
      locationName: "Start Location",
      location: MY_LOCATION,
      pinPath: "assets/driving_pin.png",
      avatarPath: "assets/friend1.jpg",
      labelColor: Colors.blueAccent,
    );

    busPinInfo = PinInformation(
      locationName: "End Location",
      location: BUS_LOCATION,
      pinPath: "assets/destination_map_marker.png",
      avatarPath: "assets/friend2.jpg",
      labelColor: Colors.purple,
    );

    // my pin
    if (myPosition != null)
      _markers.putIfAbsent(
        'myPin',
        () => Marker(
          markerId: MarkerId('myPin'),
          position: myPosition,
          onTap: () {
            currentlySelectedPin = myPinInfo;
            setPinPillPosition(0);
          },
          icon: busLocationIcon,
        ),
      );

    // bus pin
    _markers.putIfAbsent(
      'busPin',
      () => Marker(
        markerId: MarkerId('busPin'),
        position: busPosition,
        onTap: () {
          currentlySelectedPin = busPinInfo;
          setPinPillPosition(60);
        },
        icon: busLocationIcon,
      ),
    );
  }

  void updatePinsOnMap() async {
    // create a new CameraPosition instance
    // every time the location changes, so the camera
    // follows the pin as it moves with an animation
    CameraPosition cPosition = CameraPosition(
      zoom: CAMERA_ZOOM,
      tilt: CAMERA_TILT,
      bearing: CAMERA_BEARING,
      target: LatLng(busLocationData.latitude, busLocationData.longitude),
    );

    final GoogleMapController controller = await myController.future;

    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
    // updated position
    LatLng pinPosition =
        LatLng(busLocationData.latitude, busLocationData.longitude);

    busPinInfo.location = pinPosition;

    _markers.update(
      'busPin',
      (marker) => Marker(
          markerId: MarkerId('sourcePin'),
          onTap: () {
            currentlySelectedPin = busPinInfo;
            setPinPillPosition(60);
          },
          position: pinPosition, // updated position
          icon: busLocationIcon),
    );

    notifyListeners();
  }
}
