import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uberdriverapp/mapStyleCustom.dart';
import 'package:uberdriverapp/map_info.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Completer<GoogleMapController> controllerGMaoCompleter =
      Completer<GoogleMapController>();

  GoogleMapController? controllerGMapInstance;

  double paddingFromBottomGMap = 0;

  Position? userLivePosition;

  obtainuserLivePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return;
    }

    LocationPermission persmission = await Geolocator.checkPermission();

    if (persmission == LocationPermission.denied) {
      persmission = await Geolocator.requestPermission();
    }
    if (persmission == LocationPermission.denied) {
      return;
    }
    if (persmission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      return;
    }
    Position userCurrentPosition = await Geolocator.getCurrentPosition();
    userLivePosition = userCurrentPosition;

    LatLng latLangUserPosition = LatLng(
      userCurrentPosition.latitude,
      userCurrentPosition.longitude,
    );

    CameraPosition cp = CameraPosition(target: latLangUserPosition, zoom: 16);

    controllerGMapInstance!.animateCamera(CameraUpdate.newCameraPosition(cp));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(top: 27, bottom: paddingFromBottomGMap),
            mapType: MapType.normal,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            initialCameraPosition: defaultLocation,
            style: mapStyleCustom,
            onMapCreated: (GoogleMapController mapControllerGoogle) {
              controllerGMapInstance = mapControllerGoogle;
              controllerGMaoCompleter.complete(controllerGMapInstance);

              setState(() {
                paddingFromBottomGMap = 302;
              });
              obtainuserLivePosition();
            },
          ),
        ],
      ),
    );
  }
}
