
import 'package:flutter/material.dart';
import 'package:tracker_app/extensions.dart';
import 'package:tracker_app/io/location.dart';
import 'package:tracker_app/nav/recording.dart';

class RecordingsWidget extends StatefulWidget {
  const RecordingsWidget({super.key});

  @override
  State<RecordingsWidget> createState() => _RecordingsState();
}

class _RecordingsState extends State<RecordingsWidget> {

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
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
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => RecordingWidget(source: snapshot.data![index]),
                    ),
                  );
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
    );
  }
}
