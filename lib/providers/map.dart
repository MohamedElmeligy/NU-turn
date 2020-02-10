import 'dart:async';

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/driver.dart';
import '../models/pin_pill_info.dart';
import '../models/user.dart';

class MapProvider with ChangeNotifier {
  static const double CAMERA_ZOOM = 16;
  static const double CAMERA_TILT = 0;
  static const double CAMERA_BEARING = 30;
  static const LatLng MY_LOCATION = LatLng(30.025994, 31.022815);
  static const LatLng BUS_LOCATION = LatLng(30.0432003, 31.1889163);

  Firestore dbRef = Firestore();

  bool firstFetch = true;

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
  BitmapDescriptor driverLocationIcon;

  // in case the user is a student
  LatLng studentPosition;
  Map<String, Driver> _drivers = Map<String, Driver>();

  // in case the user is a driver
  LatLng currentDriverPosition;

  // user's initial location and current location
  LocationData userLocationData;

  // wrapper around the location API
  Location userLocator;

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
    pinPath: 'assets/destination_map_marker.png',
    avatarPath: 'assets/student.png',
    name: '',
    phone: '',
    id: '',
    labelColor: Colors.purpleAccent,
  );

  // current user's profile
  User user;

  SharedPreferences _prefs;

  StreamSubscription<LocationData> _userLocatorListener;

  Future<void> fetchLocalUser() async {
    _prefs = await SharedPreferences.getInstance();
    String _uid = _prefs.getString('uid');
    String _phone = _prefs.getString('phone');
    String _name = _prefs.getString('name');
    String _id = _prefs.getString('id');
    String _identity = _prefs.getString('identity');

    user = User(
      uid: _uid,
      phone: _phone,
      name: _name,
      id: _id,
      identity: _identity,
    );

    return;
  }

  void signout() {
    _prefs.clear();
    if (_userLocatorListener != null) _userLocatorListener.cancel();
  }

  //////////                     Defualt construction                     //////////
  ///
  MapProvider({this.user}) {
    // set custom marker pins
    setMyAndBusIcons();

    userLocator = Location();

    fetchLocalUser().then((_) {
      print(user.uid);
      if (user.identity == "student") {
        // set student pin info 'myPinInfo'
        myPinInfo = PinInformation(
          name: user.name,
          phone: user.phone,
          id: user.id,
          pinPath: "assets/destination_map_marker.png",
          avatarPath: "assets/student.png",
          labelColor: Colors.blueAccent,
        );

        //  check whether or not this student has a request; if a request is filed, fetch it
        dbRef
            .collection('students')
            .document('${user.uid}')
            .get()
            .then((request) {
          if (request.exists) {
            setMyLocation(
              remove: false,
            );
          }
        });

        // subscribe to changes to 'drivers' location on Firestore
        dbRef.collection('drivers').snapshots().listen(
          (drivers) {
            _drivers.clear();
            _markers.removeWhere((key, value) => key != user.uid);

            if (drivers.documents.isNotEmpty) {
              currentDriverPosition = LatLng(
                  drivers.documents[0].data['position'].latitude,
                  drivers.documents[0].data['position'].longitude);

              drivers.documents.forEach(
                (driver) {
                  Driver updatedDriver = Driver(
                    name: driver.data['name'],
                    phone: driver.data['phone'],
                    position: driver.data['position'],
                    id: '',
                  );

                  _drivers.update(
                    driver.documentID,
                    (oldDriver) => updatedDriver,
                    ifAbsent: () => updatedDriver,
                  );

                  Marker updatedDriverMarker = Marker(
                    markerId: MarkerId(driver.documentID),
                    onTap: () {
                      currentlySelectedPin = PinInformation(
                        name: driver.data['name'],
                        phone: driver.data['phone'],
                        labelColor: Colors.blueAccent,
                        id: '',
                        pinPath: 'assets/driving_pin.png',
                        avatarPath: 'assets/driver.png',
                      );
                      setPinPillPosition(60);
                    },
                    position: LatLng(
                      driver.data['position'].latitude,
                      driver.data['position'].longitude,
                    ), // updated position
                    icon: driverLocationIcon,
                  );

                  _markers.update(
                    driver.documentID,
                    (oldMarker) => updatedDriverMarker,
                    ifAbsent: () => updatedDriverMarker,
                  );
                },
              );
            }

            if (firstFetch) {
              updatePinsOnMap(currentDriverPosition);
              firstFetch = false;
            } else
              notifyListeners();
          },
        );
      } else {
        ////////////                                for licenced drivers accounts
        ///
        checkLocationPermissionAndService().then((value) {
          // subscribe to changes in the bus's location
          // by "listening" to the location's onLocationChanged event
          _userLocatorListener =
              userLocator.onLocationChanged().listen((LocationData cLoc) {
            // cLoc contains the lat and long of the
            // current bus's position in real time,
            // so we're holding on to it
            userLocationData = cLoc;
            currentDriverPosition =
                LatLng(userLocationData.latitude, userLocationData.longitude);

            if (firstFetch) {
              updatePinsOnMap(currentDriverPosition);
              firstFetch = false;
            }

            dbRef.collection('drivers').document(user.uid).setData({
              "name": user.name,
              "phone": user.phone,
              "position": GeoPoint(
                currentDriverPosition.latitude,
                currentDriverPosition.longitude,
              ),
            });

            Marker updatedDriverMarker = Marker(
              markerId: MarkerId(user.uid),
              onTap: () {
                currentlySelectedPin = PinInformation(
                  name: user.name,
                  phone: user.phone,
                  labelColor: Colors.blueAccent,
                  id: '',
                  pinPath: 'assets/driving_pin.png',
                  avatarPath: 'assets/driver.png',
                );
                setPinPillPosition(60);
              },
              position: LatLng(
                currentDriverPosition.latitude,
                currentDriverPosition.longitude,
              ), // updated position
              icon: driverLocationIcon,
            );

            _markers.update(
              user.uid,
              (oldMarker) => updatedDriverMarker,
              ifAbsent: () => updatedDriverMarker,
            );

            notifyListeners();
          });

          dbRef.collection('students').snapshots().listen((students) {
            _markers.removeWhere((key, value) => key != user.uid);

            students.documents.forEach((student) {
              Marker studentMarker = Marker(
                markerId: MarkerId(student.documentID),
                onTap: () {
                  currentlySelectedPin = PinInformation(
                    name: student.data['name'],
                    phone: student.data['phone'],
                    labelColor: Colors.deepPurple,
                    id: '',
                    pinPath: 'assets/destination_map_marker.png',
                    avatarPath: 'assets/student.png',
                  );
                  setPinPillPosition(60);
                },
                position: LatLng(
                  student.data['position'].latitude,
                  student.data['position'].longitude,
                ), // updated position
                icon: myLocationIcon,
              );

              _markers.update(
                student.documentID,
                (oldMarker) => studentMarker,
                ifAbsent: () => studentMarker,
              );
            });

            notifyListeners();
          });
        });
      }
    });

    // animate map camera to first driver in list
    initialCameraPosition = CameraPosition(
      zoom: CAMERA_ZOOM,
      tilt: CAMERA_TILT,
      bearing: CAMERA_BEARING,
      target: currentDriverPosition ?? BUS_LOCATION,
    );
  }

  Future<bool> checkLocationPermissionAndService() async {
    bool permission = await userLocator.hasPermission().then((hasPermission) {
      if (hasPermission) return true;
      return userLocator.requestPermission();
    });

    if (!permission) {
      addingMyRequest = false;
      notifyListeners();
      return false;
    }

    // check for location service
    bool service = await userLocator.serviceEnabled().then((serviceEnabled) {
      if (serviceEnabled) return true;
      return userLocator.requestService();
    });

    if (!service) {
      addingMyRequest = false;
      notifyListeners();
      return false;
    } else {
      return Future.delayed(Duration(milliseconds: 2000), () => true);
    }
  }

  void setMyLocation({
    @required bool remove,
  }) async {
    addingMyRequest = true;
    notifyListeners();

    // check for location permission
    await checkLocationPermissionAndService().then((response) async {
      if (response) {
        //////  checks passed! safe to proceed

        if (remove) {
          _markers.remove(user.uid);
          _requestedRide = false;

          dbRef.collection('students').document('${user.uid}').delete();

          updatePinsOnMap(currentDriverPosition);
        } else {
          _requestedRide = true;

          userLocationData = await userLocator.getLocation();
          studentPosition =
              LatLng(userLocationData.latitude, userLocationData.longitude);

          Marker myMarker = Marker(
            markerId: MarkerId(user.uid),
            position: studentPosition,
            onTap: () {
              currentlySelectedPin = myPinInfo;
              setPinPillPosition(60);
            },
            icon: myLocationIcon,
          );

          _markers.update(
            user.uid,
            (marker) => myMarker,
            ifAbsent: () => myMarker,
          );

          dbRef.collection('students').document('${user.uid}').setData({
            "name": user.name,
            "phone": user.phone,
            "id": user.id,
            "position":
                GeoPoint(studentPosition.latitude, studentPosition.longitude),
          });

          await updatePinsOnMap(studentPosition);
        }
      }
      print("${studentPosition.latitude}  ${studentPosition.longitude}");
    });
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

    driverLocationIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      'assets/driving_pin.png',
    );
  }

  Future<void> updatePinsOnMap(LatLng newPosition) async {
    // create a new CameraPosition instance

    CameraPosition cPosition = CameraPosition(
      zoom: CAMERA_ZOOM,
      tilt: CAMERA_TILT,
      bearing: CAMERA_BEARING,
      target: newPosition,
    );

    final GoogleMapController controller = await myController.future;

    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
    // updated position

    notifyListeners();
  }
}
