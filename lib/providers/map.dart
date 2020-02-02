import 'dart:async';

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:uturn/models/user.dart';

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

  // for storing pins to be viewed on map
  Map<String, Marker> _markers = Map<String, Marker>();
  Set<Marker> get markers => (_markers.values.toSet());

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

  // information card is, initially, hidden
  double _pinPillPosition = -60;
  double get pinPillPosition => _pinPillPosition;

  // initially, no selected pin; information card empty
  PinInformation currentlySelectedPin = PinInformation(
    pinPath: '',
    avatarPath: '',
    name: '',
    phone: '',
    id: '',
    labelColor: Colors.grey,
  );

  PinInformation myPinInfo;
  PinInformation busPinInfo = PinInformation(
    pinPath: 'assets/driving_pin.png',
    avatarPath: 'assets/friend2.jpg',
    name: '',
    phone: '',
    id: '',
    labelColor: Colors.purpleAccent,
  );

  User user;

  // Defualt construction;
  MapProvider({this.user}) {
    // set custom marker pins
    setMyAndBusIcons();

    print('heyyyy');

    if (student) {
      myLocation = Location();

      // subscribe to changes in the bus's location on Firestore
      coRef.document('driver').snapshots().listen((driver) {
        print(driver.data['position'].latitude);
        GeoPoint geo = driver.data['position'];
        busPosition = LatLng(geo.latitude, geo.longitude);
        busPinInfo.name = driver.data['name'];
        busPinInfo.phone = driver.data['phone'];

        updatePinsOnMap(true);
      });

      coRef.document('${user.uid}').get().then((user) {
        if (user.exists) {
          setMyLocation(
            remove: false,
            user: User(
              name: user.data['name'],
              phone: user.data['phone'],
              id: user.data['id'],
            ),
          );
        }
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
      target: busPosition ?? BUS_LOCATION,
    );

    // updatePinsOnMap(true);
  }

  void setMyLocation({
    @required bool remove,
    @required User user,
  }) async {
    addingMyRequest = true;
    notifyListeners();

    // check for location permission
    bool permission = await myLocation.hasPermission().then((hasPermission) {
      if (hasPermission) return true;
      return myLocation.requestPermission();
    });

    if (!permission) {
      addingMyRequest = false;
      notifyListeners();
      return;
    }

    // check for location service
    bool service = await myLocation.serviceEnabled().then((serviceEnabled) {
      if (serviceEnabled) return true;
      return myLocation.requestService();
    });

    if (!service) {
      addingMyRequest = false;
      notifyListeners();
      return;
    }

    //////  checks passed! safe to proceed
    myLocationData = await myLocation.getLocation();
    myPosition = LatLng(myLocationData.latitude, myLocationData.longitude);

    if (remove) {
      _markers.remove('myPin');
      _requestedRide = false;

      coRef.document('${user.uid}').delete();

      updatePinsOnMap(true);
    } else {
      _requestedRide = true;

      myPinInfo = PinInformation(
        name: user.name,
        phone: user.phone,
        id: user.id,
        pinPath: "assets/destination_map_marker.png",
        avatarPath: "assets/friend1.jpg",
        labelColor: Colors.blueAccent,
      );

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

      coRef.document('${user.uid}').setData({
        "name": user.name,
        "phone": user.phone,
        "id": user.id,
      });

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
      'assets/destination_map_marker.png',
    );

    busLocationIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      'assets/driving_pin.png',
    );
  }

  void showBusPinOnMap() {
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

    if (bus) {
      _markers.update(
        'busPin',
        (marker) => Marker(
          markerId: MarkerId('busPin'),
          onTap: () {
            currentlySelectedPin = busPinInfo;
            setPinPillPosition(60);
          },
          position: busPosition, // updated position
          icon: busLocationIcon,
        ),
      );
    } else {
      _markers.update(
        'myPin',
        (marker) => Marker(
          markerId: MarkerId('myPin'),
          onTap: () {
            currentlySelectedPin = myPinInfo;
            setPinPillPosition(60);
          },
          position: myPosition, // updated position
          icon: myLocationIcon,
        ),
      );
    }

    notifyListeners();
  }
}
