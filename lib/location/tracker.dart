import 'dart:async';
import 'dart:io';
import 'package:geolocator/geolocator.dart';

class LocationTracker {
  static final AndroidSettings _android = AndroidSettings(
      accuracy: LocationAccuracy.high,
      forceLocationManager: true,
      intervalDuration: const Duration(seconds: 10),
      foregroundNotificationConfig: const ForegroundNotificationConfig(
        notificationText:
        "Your location will continue to be received",
        notificationTitle: "Tracking Location in Background",
        enableWakeLock: true,
      )
  );

  static final AppleSettings _apple = AppleSettings(
    accuracy: LocationAccuracy.high,
    activityType: ActivityType.fitness,
    pauseLocationUpdatesAutomatically: false,
    showBackgroundLocationIndicator: true,
  );

  static LocationSettings get _settings {
    if (Platform.isAndroid) {
      return _android;
    } else if (Platform.isIOS || Platform.isMacOS) {
      return _apple;
    }
    return const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );
  }

  //TODO look at finalizers
  final Stream<Position> _positionStream;

  Stream<Position> get stream {
    return _positionStream;
  }

  LocationTracker()
  : _positionStream = Geolocator.getPositionStream(locationSettings: _settings);

  static Future<bool> permissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return true;
  }
}