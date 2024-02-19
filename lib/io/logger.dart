import 'dart:io';
import 'package:path_provider/path_provider.dart';

class Logger {
  Future<String> get _path async {
    final directory = await getApplicationDocumentsDirectory();

    return '${directory.path}/logs/';
  }

  File? _currentLogFile;
  /*
  Future<File> get _file async {
    final path = await _path;
    if (_currentLogFile == null) {
      final dir = Directory(path);
      final files = dir.listSync();
      _currentLogFile = File(files[0].path);
    }

    _currentLogFile?.length().then((length) => {
      if (length > 1000000) {
        //Create new log file if greater than a MB
        _currentLogFile = File('$path/${DateTime.now().millisecondsSinceEpoch}.csv');
      }
    });

    return _currentLogFile;
  }*/


  /*Logger() :
      _currentLogFile = */

  Future<void> log(String log) async {
    if (_currentLogFile == null) {
      final path = await _path;

      final dir = Directory(path);
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
      final files = dir.listSync();
      if (files.isEmpty){
        //If no log files already, create new one
        _currentLogFile = File('$path/${DateTime.now().millisecondsSinceEpoch}.txt');
      } else {
        _currentLogFile = File(files[0].path);
      }
    }

    _currentLogFile?.writeAsString("$log \n", mode: FileMode.append);

    _currentLogFile?.length().then((length) => {
      if (length > 1000000) {
        _path.then((path) => {
          //Create new log file if greater than a MB
          _currentLogFile = File('$path/${DateTime.now().millisecondsSinceEpoch}.txt')
        })
      }
    });
  }
}