
import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_app/extensions.dart';
import 'package:tracker_app/io/location.dart';

void main() {
  test('Test elapsedDateString', () async {

    //1705834916471
    //1708191237
    //1707495383607.ndjson
    String t = 1708191237000.elapsedDateString();  //2024 02 17 6:35
    print(t);
    expect(t, "2024/02/17 - Sat 06:33");
  });
}
