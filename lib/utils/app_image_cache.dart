import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:flutter/painting.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';

/// 所有网络图片共用 URL 键和原图文件；这里的目录不会导出到相册。
class AppImageCache extends CacheManager with ImageCacheManager {
  static const cacheName = 'grfa_images_v1';
  static const _metadataName = 'grfa_image_metadata';
  static final instance = AppImageCache._();

  AppImageCache._()
      : super(Config(
          cacheName,
          stalePeriod: const Duration(days: 365),
          maxNrOfCacheObjects: 3000,
          fileService: _ImageFileService(),
        ));

  final _legacy = DefaultCacheManager();
  final _emojiUrls = <String>{};
  final _jobs = <Completer<void>>{};
  final _migrations = <String, Future<void>>{};
  Completer<void>? _clearing;
  int _epoch = 0;
  int get epoch => _epoch;

  void registerEmojis(Iterable<String> urls) {
    _emojiUrls.addAll(urls.where((url) {
      final uri = Uri.tryParse(url);
      return uri != null && (uri.scheme == 'https' || uri.scheme == 'http');
    }));
  }

  /// 清理期间新任务等待；旧目录检查不能在清理完成后把数据写回来。
  Future<T> _access<T>(Future<T> Function() action, {int? expectedEpoch}) async {
    while (_clearing != null) {
      await _clearing!.future;
    }
    if (expectedEpoch != null && expectedEpoch != _epoch) {
      throw const CacheResetException();
    }
    final job = Completer<void>();
    _jobs.add(job);
    try {
      return await action();
    } finally {
      _jobs.remove(job);
      job.complete();
    }
  }

  @override
  Stream<FileResponse> getFileStream(String url,
      {String? key, Map<String, String>? headers, bool withProgress = false}) {
    final output = StreamController<FileResponse>();
    final requestEpoch = _epoch;
    // 即使调用方拿到首个缓存文件后取消订阅，也等后台验证写入完成再允许清理。
    unawaited(_access(() async {
      final cacheKey = key ?? url;
      await _migrate(url, cacheKey);
      final cached = await getFileFromCache(cacheKey);
      if (_emojiUrls.contains(url) && cached != null) {
        output.add(cached);
        return;
      }
      await for (final result in super.getFileStream(url,
          key: cacheKey, headers: headers, withProgress: withProgress)) {
        output.add(result);
      }
    }, expectedEpoch: requestEpoch).then<void>((_) {}, onError: (Object error, StackTrace stack) {
      output.addError(error, stack);
    }).whenComplete(() {
      // 不等待 close：订阅方可能已经取消，或暂停了订阅。
      unawaited(output.close());
    }));
    return output.stream;
  }

  Future<void> _migrate(String url, String key) async {
    if (await getFileFromCache(key) != null) return;
    final pending = _migrations[key];
    if (pending != null) return pending;
    final migration = _copyLegacy(url, key);
    _migrations[key] = migration;
    try {
      await migration;
    } finally {
      _migrations.remove(key);
    }
  }

  Future<void> _copyLegacy(String url, String key) async {
    final old = await _legacy.getFileFromCache(key);
    if (old == null) return;
    final record = await _legacy.store.retrieveCacheData(key);
    final extension = old.file.path.split('.').last;
    try {
      await putFileStream(url, old.file.openRead(),
          key: key,
          eTag: record?.eTag,
          maxAge: old.validTill.difference(DateTime.now()),
          fileExtension: extension);
    } on io.FileSystemException {
      // 旧文件可能已被系统回收，转为正常下载。
      return;
    }
    // 迁移成功后只保留一份原图，旧缓存缺失时正常走网络。
    await _legacy.removeFile(key);
    try {
      if (await old.file.exists()) await old.file.delete();
    } on io.FileSystemException {
      // 残留文件仍计入缓存大小，之后可由设置页清理。
    }
  }

  Future<io.File> originalFile(String url) async {
    // 等后台验证完成，避免导出旧文件期间它恰好被新版本替换。
    final result = await getFileStream(url).lastWhere((item) => item is FileInfo);
    return (result as FileInfo).file;
  }

  /// 每次打开表情面板都可调用；只补缺图，两个工作队列避免占满下载通道。
  Future<void> fillMissingEmojis(Iterable<String> urls, int expectedEpoch) async {
    final remaining = urls.toSet().iterator;
    Future<void> worker() async {
      while (_epoch == expectedEpoch && remaining.moveNext()) {
        final url = remaining.current;
        if (!_emojiUrls.contains(url)) continue;
        try {
          await originalFile(url);
        } catch (_) {
          // 缺图保留到下次补取，不因单张失败中断整个分类。
        }
      }
    }
    await Future.wait([worker(), worker()]);
  }

  Future<io.Directory> _directory(String name) async {
    final root = await getTemporaryDirectory();
    return io.Directory('${root.path}${io.Platform.pathSeparator}$name');
  }

  Future<io.File> _catalogFile() async {
    final directory = await _directory(_metadataName);
    return io.File('${directory.path}${io.Platform.pathSeparator}emojis.json');
  }

  Future<Map<String, dynamic>?> readEmojiCatalog() => _access(() async {
        try {
          final file = await _catalogFile();
          if (!await file.exists()) return null;
          final json = jsonDecode(await file.readAsString());
          return json is Map<String, dynamic> ? json : null;
        } on FormatException {
          return null;
        } on io.FileSystemException {
          return null;
        }
      });

  Future<void> writeEmojiCatalog(Map<String, dynamic> data, int expectedEpoch) =>
      _access(() async {
        final file = await _catalogFile();
        await file.parent.create(recursive: true);
        final temporary = io.File('${file.path}.tmp');
        await temporary.writeAsString(jsonEncode(data), flush: true);
        if (await file.exists()) await file.delete();
        await temporary.rename(file.path);
      }, expectedEpoch: expectedEpoch);

  /// 仅统计本功能的图片和目录文件，不扫描相册、登录数据或整个临时目录。
  Future<int> usedBytes() async {
    var bytes = 0;
    for (final name in [cacheName, DefaultCacheManager.key, _metadataName]) {
      final directory = await _directory(name);
      if (!await directory.exists()) continue;
      try {
        await for (final entry in directory.list(recursive: true, followLinks: false)) {
          if (entry is io.File) {
            try {
              bytes += await entry.length();
            } on io.FileSystemException {
              // 文件可能刚被缓存淘汰。
            }
          }
        }
      } on io.FileSystemException {
        // 统计过程中目录可能被清理。
      }
    }
    return bytes;
  }

  Future<void> clearImages() async {
    if (_clearing != null) return _clearing!.future;
    final gate = Completer<void>();
    _clearing = gate;
    _epoch++;
    try {
      await Future.wait(_jobs.map((job) => job.future).toList());
      await super.emptyCache();
      await _legacy.emptyCache();
      store.emptyMemoryCache();
      _legacy.store.emptyMemoryCache();
      // 同时删除失去索引的旧文件；只操作三个固定的 App 缓存子目录。
      for (final name in [cacheName, DefaultCacheManager.key, _metadataName]) {
        final directory = await _directory(name);
        if (await directory.exists()) await directory.delete(recursive: true);
      }
    } finally {
      _emojiUrls.clear();
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
      _clearing = null;
      gate.complete();
    }
  }
}

class CacheResetException implements Exception {
  const CacheResetException();
}

class _ImageFileService extends HttpFileService {
  _ImageFileService() {
    concurrentFetches = 6;
  }

  @override
  Future<FileServiceResponse> get(String url, {Map<String, String>? headers}) async {
    final response = await super.get(url, headers: headers)
        .timeout(const Duration(seconds: 25));
    return _TimedImageResponse(response);
  }
}

class _TimedImageResponse implements FileServiceResponse {
  _TimedImageResponse(this.response);
  final FileServiceResponse response;
  @override
  Stream<List<int>> get content => response.content.timeout(const Duration(seconds: 25));
  @override
  int? get contentLength => response.contentLength;
  @override
  int get statusCode => response.statusCode;
  @override
  DateTime get validTill => response.validTill;
  @override
  String? get eTag => response.eTag;
  @override
  String get fileExtension => response.fileExtension;
}
