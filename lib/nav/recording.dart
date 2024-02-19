/*
  View for single recording
  Allows for editing, deleting, stats
 */

import 'dart:io';
import 'dart:developer' as developer;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:tracker_app/io/location.dart';

import '../widgets/osm_attribution.dart';

class RecordingWidget extends StatefulWidget {
  final TrackInfo source;

  const RecordingWidget({super.key, required this.source});

  @override
  State<RecordingWidget> createState() => _RecordingState();
}

class _RecordingState extends State<RecordingWidget> {

  late List<LatLng> points;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    points = widget.source.positions!.map((val) => LatLng(val.latitude, val.longitude)).toList();
    mapController.mapEventStream.listen((event) {
      print("Map event: $event");
    });
  }

  //Map UI
  final mapController = MapController();

  bool _uploading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Do some stuff here with NavigationDestination"),
      ),
      body: Column(
        children: [
          /*LineChart(
            LineChartData(
              lineBarsData: LineChartBarData(
                spots:
              )
            ),
          )*/

          Expanded(child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                /*onPositionChanged: (MapPosition position, bool hasGesture) {
                  developer.log('Position Changed: $position - $hasGesture', name: 'my.app.category');
                },*/
                //interactionOptions: InteractionOptions,
                onTap: (TapPosition tapPosition, LatLng point) {
                  developer.log('Tap: $tapPosition - $point', name: 'my.app.category');
                },
                /*onLongPress: (TapPosition tapPosition, LatLng point) {
                  print("Cucker");
                  print("longPress map $tapPosition - $point");
                },*/
              ),
              children: [
                //if (_showMap)
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.sports_app',
                  ),
                //Toggle map tiles

                /*PolylineLayer(polylines: [
                  Polyline(points: points, color: Colors.blue,)
                ]),*/
                //OSMAttributionWidget(),
              ]
          ))
        ],
      ),
      /*body: FutureBuilder(
        future: TrackerStorage.tracks(),
        builder: (BuildContext context, AsyncSnapshot<List<TrackInfo>> snapshot) {
          if (snapshot.hasData) {
            print("Had data : ${snapshot.data?.length}");

            return ListView.builder(
              itemCount: snapshot.data?.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(snapshot.data?[index].start.elapsedDateString() ?? "FAILURE"),
                  onTap: () {

                  },
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),*/
    );
  }
}