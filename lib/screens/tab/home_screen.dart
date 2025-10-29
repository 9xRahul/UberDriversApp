import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uberdriverapp/driver_info.dart';
import 'package:uberdriverapp/mapStyleCustom.dart';
import 'package:uberdriverapp/map_info.dart';
import 'package:uberdriverapp/push_notofication_system/push_notofication_system.dart';

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

  Position? driverLivePosition;

  bool driverActive = false;
  Color colortoDIsplay = Colors.black;
  String titleToDisplay = "Ready To Drive";

  DatabaseReference? newRideStatusReference;

  startPushNotificationSysntem() {
    PushNotificationSystem pushNotoficationSystem = PushNotificationSystem();
    pushNotoficationSystem.saveFCMToken();

    pushNotoficationSystem.listenForNewNotification(context);
  }

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
    driverLivePosition = userCurrentPosition;

    LatLng latLangUserPosition = LatLng(
      userCurrentPosition.latitude,
      userCurrentPosition.longitude,
    );

    CameraPosition cp = CameraPosition(target: latLangUserPosition, zoom: 16);

    controllerGMapInstance!.animateCamera(CameraUpdate.newCameraPosition(cp));
  }

  readyToDrive() async {
    Geofire.initialize("liveDrivers");

    Geofire.setLocation(
      FirebaseAuth.instance.currentUser!.uid,
      driverLivePosition!.latitude,
      driverLivePosition!.longitude,
    );
    newRideStatusReference = FirebaseDatabase.instance
        .ref()
        .child('allDrivers')
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child('newRideStatus');

    await newRideStatusReference!.set("waiting");

    newRideStatusReference!.onValue.listen((eventRide) {});
  }

  makeLocationUpdates() {
    driverPositionInitialStreamSubscription = Geolocator.getPositionStream()
        .listen((Position posDriver) async {
          driverLivePosition = posDriver;
          if (driverActive == true) {
            Geofire.setLocation(
              FirebaseAuth.instance.currentUser!.uid,
              driverLivePosition!.latitude,
              driverLivePosition!.longitude,
            );
          }

          LatLng driverPositionLatLang = LatLng(
            posDriver.latitude,
            posDriver.longitude,
          );
          controllerGMapInstance!.animateCamera(
            CameraUpdate.newLatLng(driverPositionLatLang),
          );
        });
  }

  stopAcceptingRides() async {
    Geofire.removeLocation(FirebaseAuth.instance.currentUser!.uid);
    newRideStatusReference!.onDisconnect();
    newRideStatusReference!.remove();
    newRideStatusReference = null;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startPushNotificationSysntem();
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

          Container(height: 136, width: double.infinity, color: Colors.black),
          Positioned(
            top: 60,
            left: 0,
            right: 0,

            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isDismissible: false,
                      builder: (BuildContext context) {
                        return Container(
                          height: 222,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                blurRadius: 5.0,
                                spreadRadius: 0.75,
                                offset: Offset(.7, .7),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsetsGeometry.symmetric(
                              horizontal: 24,
                              vertical: 18,
                            ),
                            child: Column(
                              children: [
                                Text(
                                  (!driverActive)
                                      ? "Ready to drive"
                                      : "Stop Accepting Rides",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 18),
                                Text(
                                  (!driverActive)
                                      ? "Once online, you will be visible to users and able to recieve trip requests"
                                      : "Once offline, you will not be visible to users and unable to recieve trip requests",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsGeometry.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.black,
                                            side: BorderSide(
                                              color: Colors.grey,
                                              width: 1.0,
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text(
                                            "Cancel",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                titleToDisplay ==
                                                    "Ready To Drive"
                                                ? Colors.black
                                                : Colors.grey,
                                            side: BorderSide(
                                              color: Colors.grey,
                                              width: 1.0,
                                            ),
                                          ),
                                          onPressed: () async {
                                            if (!driverActive) {
                                              await readyToDrive();
                                              await makeLocationUpdates();
                                              Navigator.of(context).pop();
                                              setState(() {
                                                colortoDIsplay = Colors.black;
                                                titleToDisplay =
                                                    "Stop Accepting Rides";
                                                driverActive = true;
                                              });
                                            } else {
                                              await stopAcceptingRides();
                                              Navigator.of(context).pop();
                                              setState(() {
                                                colortoDIsplay = Colors.black;
                                                titleToDisplay =
                                                    "Ready to Drive";
                                                driverActive = false;
                                              });
                                            }
                                          },
                                          child: Text(
                                            "Conform",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colortoDIsplay,
                    side: BorderSide(color: Colors.grey, width: 1.0),
                  ),
                  child: Text(
                    titleToDisplay,
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
