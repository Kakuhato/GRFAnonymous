import 'dart:async';

import 'package:flutter/foundation.dart';

import '../utils/app_image_cache.dart';
import 'requestUtils.dart';

class OfficialEmoji {
  final int id;
  final String url;
  final String description;

  OfficialEmoji.fromJson(Map data)
      : id = int.tryParse('${data['id']}') ?? 0,
        url = data['url_path']?.toString() ?? '',
        description = data['url_desc']?.toString() ?? '';

  Map<String, dynamic> toJson() => {
        'id': id, 'url_path': url, 'url_desc': description,
      };
}

class EmojiCategory {
  final int id;
  final String image;
  final List<OfficialEmoji> emojis;

  EmojiCategory.fromJson(Map data)
      : id = int.tryParse('${data['classify_id']}') ?? 0,
        image = data['img_addr']?.toString() ?? '',
        emojis = (data['emoji_list'] as List? ?? [])
            .whereType<Map>().map(OfficialEmoji.fromJson).toList();

  Map<String, dynamic> toJson() => {
        'classify_id': id,
        'img_addr': image,
        'emoji_list': emojis.map((emoji) => emoji.toJson()).toList(),
      };
}

class EmojiRequest {
  static final changes = ValueNotifier<List<EmojiCategory>?>(null);
  static List<EmojiCategory>? _cache;
  static DateTime? _checkedAt;
  static DateTime? _attemptedAt;
  static Future<void>? _initializing;
  static Future<List<EmojiCategory>>? _pending;
  static Future<void>? _filling;
  static bool _fillAgain = false;
  static int _epoch = -1;

  static void _syncEpoch() {
    final current = AppImageCache.instance.epoch;
    if (_epoch == current) return;
    _epoch = current;
    _cache = null;
    _checkedAt = null;
    _attemptedAt = null;
    _initializing = null;
    _pending = null;
    _filling = null;
    _fillAgain = false;
    changes.value = null;
  }

  /// 启动时仅读取本地目录，确保正文中的表情也采用同一长期缓存策略。
  static Future<void> initialize() {
    _syncEpoch();
    return _initializing ??= _readLocal(_epoch);
  }

  static Future<void> _readLocal(int epoch) async {
    try {
      final data = await AppImageCache.instance.readEmojiCatalog();
      if (epoch != AppImageCache.instance.epoch || data == null) return;
      final list = data['list'];
      if (list is! List) return;
      final categories = list.map((item) => EmojiCategory.fromJson(item as Map)).toList();
      if (categories.isEmpty) return;
      _checkedAt = DateTime.tryParse('${data['checked_at']}');
      _accept(categories);
    } catch (_) {
      // 目录损坏时重新请求，不影响 App 启动。
    }
  }

  static Iterable<String> _urls(List<EmojiCategory> categories) sync* {
    for (final category in categories) {
      yield category.image;
      for (final emoji in category.emojis) {
        yield emoji.url;
      }
    }
  }

  static void _accept(List<EmojiCategory> categories) {
    _cache = categories;
    AppImageCache.instance.registerEmojis(_urls(categories));
    changes.value = categories;
  }

  Future<List<EmojiCategory>> load({bool refresh = false}) async {
    await initialize();
    if (_cache != null) {
      _fillMissing();
      final now = DateTime.now();
      final due = _checkedAt == null || now.difference(_checkedAt!) >= const Duration(days: 1);
      final canRetry = _attemptedAt == null || now.difference(_attemptedAt!) >= const Duration(minutes: 5);
      if (refresh || (due && canRetry)) {
        unawaited(_check().then<void>((_) {}, onError: (Object _, StackTrace __) {}));
      }
      return _cache!;
    }
    return _check();
  }

  static Future<List<EmojiCategory>> _check() async {
    final pending = _pending;
    if (pending != null) return pending;
    final epoch = _epoch;
    _attemptedAt = DateTime.now();
    final request = _fetch(epoch);
    _pending = request;
    try {
      return await request;
    } finally {
      if (identical(_pending, request)) _pending = null;
    }
  }

  static Future<List<EmojiCategory>> _fetch(int epoch) async {
    // 公共接口，不要求用户登录；沿用项目的网络配置。
    final response = await DioInstance.instance().get(path: '/community/emoji');
    final body = response.data;
    if (body is! Map || '${body['Code']}' != '0' || body['data'] is! Map) {
      throw const FormatException('表情列表加载失败');
    }
    final list = body['data']['list'];
    if (list is! List || list.isEmpty) throw const FormatException('表情列表格式异常');
    final categories = list.map((item) => EmojiCategory.fromJson(item as Map)).toList();
    if (epoch != AppImageCache.instance.epoch) throw const CacheResetException();
    // 按角色分类数量判断新增；相同数量时不替换现有目录及旧图片。
    if (_cache == null || categories.length > _cache!.length) _accept(categories);
    _checkedAt = DateTime.now();
    try {
      await AppImageCache.instance.writeEmojiCatalog({
        'checked_at': _checkedAt!.toIso8601String(),
        'list': _cache!.map((category) => category.toJson()).toList(),
      }, epoch);
    } on CacheResetException {
      rethrow;
    } catch (_) {
      // 磁盘暂时不可写仍可使用本次目录，下次检查时重试持久化。
    }
    if (epoch != AppImageCache.instance.epoch) throw const CacheResetException();
    _fillMissing();
    return _cache!;
  }

  static void _fillMissing() {
    _fillAgain = true;
    if (_filling != null) return;
    final epoch = _epoch;
    final task = _fillLoop(epoch);
    _filling = task;
    unawaited(task.whenComplete(() {
      if (identical(_filling, task)) _filling = null;
    }));
  }

  static Future<void> _fillLoop(int epoch) async {
    while (_fillAgain && epoch == AppImageCache.instance.epoch) {
      _fillAgain = false;
      final categories = _cache;
      if (categories == null) return;
      await AppImageCache.instance.fillMissingEmojis(_urls(categories), epoch);
    }
  }

  static Future<void> clearCache() async {
    final clearing = AppImageCache.instance.clearImages();
    _syncEpoch();
    await clearing;
  }
}
