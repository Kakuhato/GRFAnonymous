import 'requestUtils.dart';

class OfficialEmoji {
  final int id;
  final String url;
  final String description;

  OfficialEmoji.fromJson(Map data)
      : id = int.tryParse('${data['id']}') ?? 0,
        url = data['url_path']?.toString() ?? '',
        description = data['url_desc']?.toString() ?? '';
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
}

class EmojiRequest {
  static List<EmojiCategory>? _cache;
  static DateTime? _cachedAt;
  static Future<List<EmojiCategory>>? _pending;

  Future<List<EmojiCategory>> load({bool refresh = false}) async {
    if (!refresh && _cache != null && _cachedAt != null &&
        DateTime.now().difference(_cachedAt!) < const Duration(hours: 1)) {
      return _cache!;
    }
    final pending = _pending;
    if (pending != null) return pending;
    final request = _fetch();
    _pending = request;
    try {
      return await request;
    } finally {
      _pending = null;
    }
  }

  Future<List<EmojiCategory>> _fetch() async {
    // 公共接口，不要求用户登录；沿用项目的网络配置。
    final response = await DioInstance.instance().get(path: '/community/emoji');
    final body = response.data;
    if (body is! Map || '${body['Code']}' != '0' || body['data'] is! Map) {
      throw const FormatException('表情列表加载失败');
    }
    final list = body['data']['list'];
    if (list is! List) throw const FormatException('表情列表格式异常');
    final categories = list.map((item) => EmojiCategory.fromJson(item as Map)).toList();
    _cache = categories;
    _cachedAt = DateTime.now();
    return categories;
  }
}
