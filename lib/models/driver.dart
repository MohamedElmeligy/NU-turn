import 'package:flutter/foundation.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class Driver {
  String name;
  String phone;
  String id;
  GeoPoint position;

  Driver({
    @required this.name,
    @required this.phone,
    @required this.id,
    @required this.position,
  });
}
