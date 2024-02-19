
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_app/io/location.dart';

void testRecording(File file, {int? expectedStart, int? expectedEnd, int? expectedPositions}) async {
  file.readAsString();

  var read = await TrackerStorage.read(file);
  expect(read, isNotNull);

  //TODO
}

void main() {
  test('Test reading small track - 14kb', () async {
    final small = File("test/resources/tracks/1705834916389.ndjson");
    testRecording(small);
  });

  test('Test reading medium track - 62kib', () async {
    final medium = File("test/resources/tracks/1706012426256.ndjson");
    testRecording(medium);
  });

  test('Test reading large track - 224kb', () async {
    final large = File("test/resources/tracks/1707495383607.ndjson");
    testRecording(large);
  });

  test('Test malformed track reading - 0kb', () async {
    //rootBundle.loadString()
    final f = File("test/resources/tracks/1706345469947.ndjson");

    var fs = await TrackerStorage.read(f);
    print("FS: $fs");
    expect(fs, isNotNull);
  });

  test('Test empty track reading - 78kb', () async {
    //rootBundle.loadString()
    final f = File("test/resources/tracks/1800000000000.ndjson");
    //Fri Jan 15 2027 08:00:00

    var fs = await TrackerStorage.read(f);
    print("FS: $fs");
    expect(fs, isNotNull);
    expect(fs?.start, 1800000000000);
  });
}
