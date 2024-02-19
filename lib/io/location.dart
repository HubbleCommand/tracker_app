import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tracker_app/extensions.dart';


class TrackSummary {

}
class TrackInfo {
  final File file;
  final int start;
  final int end;
  final Float? distance;
  final List<Position>? positions;

  TrackInfo(this.file, {required this.start, required this.end, required this.distance, required this.positions});
}

extension Chart on TrackInfo {
  /*List<FlSpot> toSpots() {

  }*/
}

class TrackerStorage {
  static Future<String> get _root async {
    final directory = await getApplicationDocumentsDirectory();

    return "${directory.path}/tracks";
  }

  static Future<List<FileSystemEntity>> files({String? path}) async {
    final _path = path ?? await _root;
    final dir = Directory(_path);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
      return [];
    }

    //Order the entries
    var files = dir.listSync();
    files.sort((a, b) => a.name().compareTo(b.name()));
    return files;
  }

  static Future<List<TrackInfo>> tracks() async {
    final records = await files();

    List<TrackInfo> ret = [];

    for (final record in records) {
      //Only need to read the first few lines: start time and start position
      var cunt = await read(File(record.path));
      print("Cunt: $cunt");
      if (cunt != null) {
        ret.add(cunt);
      }
    }

    return ret;
  }

  //static Future<List<Position>> read(FileSystemEntity fse) async {
  static Future<TrackInfo?> read(File file) async {
    try {
      //final file = File(fse.path);

      // Read the file
      final contents = await file.readAsString();
      final lines = contents.split("\n");

      bool csv = false;
      if (lines[0].allMatches(",").length > 2) {
        csv = true;
      }
      int start = -1;
      int end = -1;
      Float? distance;
      List<Position> positions = [];
      for (final line in lines) {
        if (line.isEmpty) {
          continue;
        }
        if (csv) {
          //If CSV
          var split = line.split(',');
          //TODO handle different CSV header mapping
          positions.add(Position.fromMap({
            'timestamp': split[0],
            'latitude': split[1],
            'longitude': split[2],
            'accuracy': split[3],
            'altitude': split[4],
            'altitude_accuracy': split[5],
            'heading': split[6],
            'heading_accuracy': split[7],
            'speed': split[8],
            'speed_accuracy': split[9],
            'is_mocked': split[10],
          }));
        } else {
          //Try to parse line into an object
          if (line.contains("position")) {
            try {
              //print("Going to decode: ${json.decode(utf8.decode(line))}");
              print("Going to decode: ${json.decode(line)['position']}");
              positions.add(Position.fromMap(json.decode(line)['position']));
            } catch (e) {
              print("Failed with ${e} to parse line: $line");
              //Probably start or end line
            }
          } else {
            try {
              final json = jsonDecode(line);
              start = json['start'] ?? start;
              end = json['end'] ?? end;
            } catch (e) {

            }
          }
        }
      }
      if (positions.isNotEmpty) {
        if (start < 0) {
          start = positions.first.timestamp.second;
        }
        if (end < 0) {
          end = positions.last.timestamp.second;
        }
      }

      if (start < 0) {
        start = int.parse(file.name());
      }

      return TrackInfo(file, start: start, end: end, distance: distance, positions: positions);
    } catch (e) {
      print("Fucker : $e");
      return null;
    }
  }

  File? currentFile;

  Future<void> start() async {
    if (currentFile != null) {
      currentFile?.writeAsString('{"end"":${DateTime.now().millisecondsSinceEpoch}}\n', mode: FileMode.append);
    }
    final path = await _root;
    currentFile = File('$path/${DateTime.now().millisecondsSinceEpoch}.ndjson');
    await currentFile?.create(recursive: true);
    currentFile?.writeAsString('{"start":${DateTime.now().millisecondsSinceEpoch}}\n', mode: FileMode.append);
  }

  Future<void> stop() async {
    if (currentFile != null) {
      currentFile?.writeAsString("{'end':${DateTime.now().millisecondsSinceEpoch}}\n", mode: FileMode.append);
    }
    currentFile = null;
  }

  Future<void> write(Position position) async {
    currentFile?.writeAsString('{"position":${json.encode(position.toJson())}}\n', mode: FileMode.append);
  }
}
