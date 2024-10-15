

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class FileUtil {


  static Future<String> getApplicationDir() async {
    var path = (await getApplicationSupportDirectory()).path;
    if (kDebugMode) {
      path += "-Debug";
    }
    Directory directory = Directory(path);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return path;
  }

  static Future<String> getCookieDir() async{
    Directory directory = Directory("${await getApplicationDir()}/.cookies/");
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory.path;
  }


}