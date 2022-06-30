import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class Cache {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<String?> getCached(String fileName) async {
    try {
      final path = await _localPath;
      final file = File('$path/$fileName.txt');
      return await file.readAsString();
    } catch (e) {
      return null;
    }
  }

  Future<File> saveCached(String fileName, String data) async {
    final path = await _localPath;
    final file = File('$path/$fileName.txt');
    return file.writeAsString(data);
  }
}
