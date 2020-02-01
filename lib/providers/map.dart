import 'dart:async';

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import '../models/pin_pill_info.dart';

class MapProvider with ChangeNotifier {
  static const double CAMERA_ZOOM = 16;
  static const double CAMERA_TILT = 0;
  static const double CAMERA_BEARING = 30;
  static const LatLng MY_LOCATION = LatLng(30.025994, 31.022815);
  static const LatLng BUS_LOCATION = LatLng(30.0432003, 31.1889163);

  CollectionReference coRef = Firestore().collection('positions');

  bool student = true;

  bool _requestedRide = false;
  bool addingMyRequest = false;

  void setRequestedRide(bool req) {
    _requestedRide = req;
    notifyListeners();
  }

  bool get requestedRide => _requestedRide;

  Completer<GoogleMapController> myController = Completer();

  Map<String, Marker> _markers = Map<String, Marker>();

// Google API Key
  String googleAPIKey = 'AIzaSyCkNE0xD2eBlnda-PI6jOjrBRiK85BM0Do';

// for my custom marker pins
  BitmapDescriptor myLocationIcon;
  BitmapDescriptor busLocationIcon;

  LatLng myPosition;
  LatLng busPosition;

// the bus's initial location and current location
// as it moves
  LocationData myLocationData;
  LocationData busLocationData;

// wrapper around the location API
  Location myLocation;
  Location busLocation;

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
    if (student) {
      myLocation = Location();

      coRef.document('driver').snapshots().listen((data) {
        print(data.data['position'].latitude);
        GeoPoint geo = data.data['position'];
        busPosition = LatLng(geo.latitude, geo.longitude);
        updatePinsOnMap(true);
      });
    } else {
      busLocation = Location();
      // subscribe to changes in the bus's location
      // by "listening" to the location's onLocationChanged event
      busLocation.onLocationChanged().listen((LocationData cLoc) {
        // cLoc contains the lat and long of the
        // current bus's position in real time,
        // so we're holding on to it
        busLocationData = cLoc;
        busPosition =
            LatLng(busLocationData.latitude, busLocationData.longitude);
        coRef.document('driver').updateData({
          "position": GeoPoint(busPosition.latitude, busPosition.longitude),
        });

        updatePinsOnMap(true);
      });
    }

    initialCameraPosition = CameraPosition(
      zoom: CAMERA_ZOOM,
      tilt: CAMERA_TILT,
      bearing: CAMERA_BEARING,
      target: BUS_LOCATION,
    );

    // set custom marker pins
    setMyAndBusIcons();
  }

  Set<Marker> get markers => (_markers.values.toSet());
  double get pinPillPosition => _pinPillPosition;

  void setMyLocation(bool remove) async {
    addingMyRequest = true;
    notifyListeners();

    bool permission = await myLocation.hasPermission().then((hasPermission) {
      if (hasPermission) return true;
      return myLocation.requestPermission();
    });

    if (!permission) {
      addingMyRequest = false;
      notifyListeners();
      return;
    }

    bool service = await myLocation.serviceEnabled().then((serviceEnabled) {
      if (serviceEnabled) return true;
      return myLocation.requestService();
    });

    if (!service) {
      addingMyRequest = false;
      notifyListeners();
      return;
    }

    myLocationData = await myLocation.getLocation();
    myPosition = LatLng(myLocationData.latitude, myLocationData.longitude);

    if (remove) {
      _markers.remove('myPin');
      _requestedRide = false;
      updatePinsOnMap(true);
    } else {
      _requestedRide = true;
      _markers.update(
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
      updatePinsOnMap(false);
    }

    addingMyRequest = false;
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

  void updatePinsOnMap(bool bus) async {
    // create a new CameraPosition instance
    // every time the location changes, so the camera
    // follows the pin as it moves with an animation
    CameraPosition cPosition = CameraPosition(
      zoom: CAMERA_ZOOM,
      tilt: CAMERA_TILT,
      bearing: CAMERA_BEARING,
      target: bus ? busPosition : myPosition,
    );

    final GoogleMapController controller = await myController.future;

    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
    // updated position

    myPinInfo.location = myPosition;
    busPinInfo.location = busPosition;

    _markers.update(
      bus ? 'busPin' : 'myPin',
      (marker) => Marker(
        markerId: MarkerId(bus ? 'busPin' : 'myPin'),
        onTap: () {
          currentlySelectedPin = bus ? busPinInfo : myPinInfo;
          setPinPillPosition(60);
        },
        position: bus ? busPosition : myPosition, // updated position
        icon: bus ? busLocationIcon : myLocationIcon,
      ),
    );

    notifyListeners();
  }
}
