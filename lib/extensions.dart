import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';

extension LatLong on Position {
  LatLng toLatLng() {
    return LatLng(latitude, longitude);
  }
}

extension Str on int {
  //If in seconds
  String elapsedTimeString({bool forceHours = false, bool showSeconds = true}) {
    Duration duration = Duration(seconds: this);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    var hours_ = duration.inHours.remainder(60);
    String hours = forceHours ? twoDigits(hours_) : hours_.toString();
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

    return "${hours.isNotEmpty ? "$hours:" : ""}$twoDigitMinutes:${showSeconds ? twoDigitSeconds : ""}";
  }

  //If in hours
  String elapsedDateString() {
    //return DateFormat.yMMMd().format((DateTime(this))) + elapsedTimeString(forceHours: true, showSeconds: false);
    //return DateFormat("yMd : Hm").format((DateTime(this)));
    //return DateFormat("yyyy MMM EEE hh:mm").format((DateTime.fromMillisecondsSinceEpoch(this * 1000)));
    //return DateFormat("yyyy MMM d hh:mm").format((DateTime.fromMillisecondsSinceEpoch(this * 1000)));
    return DateFormat("yyyy/MM/dd - EEE hh:mm").format((DateTime.fromMillisecondsSinceEpoch(this)));
  }
}

extension NameF on File {
  String name() {
    return uri.pathSegments.last.split(".").first;
  }

  String extension() {
    return uri.pathSegments.last.split(".").last;
  }
}

extension NameFSE on FileSystemEntity {
  String name() {
    return uri.pathSegments.last.split(".").first;
  }

  String extension() {
    return uri.pathSegments.last.split(".").last;
  }
}
