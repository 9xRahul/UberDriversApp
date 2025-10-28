import 'dart:async';

import 'package:firebase_database/ui/utils/stream_subscriber_mixin.dart';
import 'package:geolocator/geolocator.dart';

String nameOfDriver = "";
String phoneOfDriver = "";
String carType = "";
String carColor = "";
String carModel = "";
String carNumber = "";

StreamSubscription<Position>? driverPositionInitialStreamSubscription;
