import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PushNotificationSystem {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future<String?> saveFCMToken() async {
    String? recognitionTokenForDevice = await messaging.getToken();

    DatabaseReference tokenRef = FirebaseDatabase.instance
        .ref()
        .child("allDrivers")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("fcmToken");

    tokenRef.set(recognitionTokenForDevice);

    messaging.subscribeToTopic('allDrivers');
    messaging.subscribeToTopic('allUsers');
  }

  listenForNewNotification(BuildContext context) async {
    FirebaseMessaging.instance.getInitialMessage().then((
      RemoteMessage? message,
    ) {
      if (message != null) {
        String rideId = message.data['rideID'];
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage? message) {
      if (message != null) {
        String rideId = message.data['rideID'];
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? message) {
      if (message != null) {
        String rideId = message.data['rideID'];
      }
    });
  }

  Future<void> requestNotificationPermission() async {
    if (Platform.isAndroid) {
      if (await Permission.notification.isDenied) {
        await Permission.notification.request();
      }
    }
  }
}
