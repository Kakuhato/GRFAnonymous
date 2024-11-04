import 'dart:io';
import 'package:flutter/services.dart';
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

  static Future<String> getCookieDir() async {
    Directory directory = Directory("${await getApplicationDir()}/.cookies/");
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory.path;
  }



}



class AlbumDirectoryHelper {
  static const MethodChannel _channel = MethodChannel('album_directory_helper');

  static Future<String?> getDefaultAlbumDirectory() async {
    try {
      final String? path = await _channel.invokeMethod('getDefaultAlbumDirectory');
      return path;
    } on PlatformException catch (e) {
      print("获取默认相册目录失败: ${e.message}");
      return null;
    }
  }
}

