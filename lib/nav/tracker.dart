
import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:tracker_app/extensions.dart';
import 'package:tracker_app/location/tracker.dart';
import 'package:tracker_app/widgets/osm_attribution.dart';

import '../io/location.dart';
import '../io/logger.dart';

class TrackerWidget extends StatefulWidget {
  const TrackerWidget({super.key});

  @override
  State<TrackerWidget> createState() => _TrackerState();
}

class _TrackerState extends State<TrackerWidget> {
  TrackerStorage storage = TrackerStorage();
  LocationTracker tracker = LocationTracker();
  Logger logger = Logger();
  bool _tracking = false;
  final Stopwatch _stopwatch = Stopwatch();
  StreamSubscription<Position>? positionStream;

  List<Position> currentTrack = [];

  int elapsedSeconds = 0;
  Timer? stopwatchUpdateTimer;

  final mapController = MapController();

  bool _showMap = true;

  //CAN STOöö SEE [ERROR:flutter/runtime/dart_vm_initializer.cc(41)] Unhandled Exception: Location services are disabled.
  void _toggleTracking() {
    if (!_tracking) {
      currentTrack.clear();
      setState(() {
        currentTrack = [];
      });
      _stopwatch.reset();
      storage.start();
      positionStream = tracker.stream.listen((Position? position) {
        if (kDebugMode) {
          print(position == null ? 'Unknown' : '${position.latitude.toString()}, ${position.longitude.toString()}');
        }
        if (position != null) {
          storage.write(position);
          setState(() {
            currentTrack.add(position);
            currentTrack = currentTrack;
          });
          //TODO if camera close enough, don't move
          // don't move if user moving the map himself (have function to re-center camera or whatever)
          mapController.move(position.toLatLng(), mapController.camera.zoom);
        }
      });
      logger.log("New tracker - ${DateTime.now().millisecondsSinceEpoch}");
      _stopwatch.start();

      stopwatchUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          elapsedSeconds = (_stopwatch.elapsedMilliseconds / 1000).round();
        });
      });
    } else {
      positionStream?.cancel();
      positionStream = null;
      storage.stop();
      _stopwatch.stop();
      stopwatchUpdateTimer?.cancel();
    }
    setState(() {
      _tracking = !_tracking;
    });
  }

  @override
  Widget build(BuildContext context) {
    var battery = Battery();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[

        FutureBuilder(future: LocationTracker.permissions(), builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasError) {
            return Card(
              shadowColor: Colors.white54,
              surfaceTintColor: Colors.white54,
              margin: const EdgeInsets.all(8.0),
              child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber),
                        Text(snapshot.error as String)
                      ],
                    ),
                  )
              ),
            );
          }
          return const SizedBox.shrink();
        }),

        FutureBuilder(future: battery.isInBatterySaveMode, builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data!) {
            return const SizedBox.shrink();
          }
          return const Card(
            shadowColor: Colors.white54,
            surfaceTintColor: Colors.white54,
            margin: EdgeInsets.all(8.0),
            child: SizedBox.shrink(
              child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber),
                        Text("Battery saver mode bad")
                      ],
                    ),
                  )
              ),
            ),
          );
        }),

        Text(
          _tracking ? 'Tracking' : 'Not Tracking',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        if (_tracking)
          Text(
            elapsedSeconds.elapsedTimeString(),
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
        //Expanded(child: MapWidget())
        Expanded(child: FlutterMap(
            mapController: mapController,
            options: const MapOptions(

            ),
            children: [
              if (_showMap)
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.sports_app',
                ),
              //Toggle map tiles
              IconButton(
                  icon: Icon(_showMap ? Icons.layers_clear : Icons.layers),
                  onPressed: () {
                    setState(() {
                      _showMap = !_showMap;
                    });
                  }
              ),

              //Start / Stop button
              Align(
                alignment: FractionalOffset.bottomCenter,
                child: MaterialButton(
                  onPressed: () => {},
                  child: ElevatedButton(
                      style: IconButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(18)
                      ),
                      onPressed: _toggleTracking,
                      child: Icon(_tracking ? Icons.stop : Icons.play_arrow)
                  ),
                ),
              ),

              //Info
              Align(
                alignment: FractionalOffset.centerRight,
                child: ElevatedButton(
                    style: IconButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(18)
                    ),
                    onPressed: () {
                      showModalBottomSheet(context: context, builder: (BuildContext context) {
                        return Container(child: Text("Tes t"));
                      });
                    },
                    child: const Icon(Icons.data_exploration) //bar_chart
                ),
              ),

              /*MarkerLayer(markers: currentTrack.map((val) => Marker(point: LatLng(val.latitude, val.longitude), width: 24, height: 24,
                      child: const Icon(Icons.radio_button_checked, color: Colors.blue, size: 24.0,))).toList()),*/
              PolylineLayer(polylines: [
                Polyline(points: currentTrack.map((val) => LatLng(val.latitude, val.longitude)).toList(), color: Colors.blue,)
              ]),
              OSMAttributionWidget(),
            ]
        ))
      ],
    );
  }

  @override
  void dispose() {
    //TODO dispose of shit here
    super.dispose();
  }
}
