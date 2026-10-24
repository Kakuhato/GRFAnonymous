/// 帖子分享格式及搜索框中的帖子 ID 识别。
class TopicLink {
  TopicLink._();

  static String shareText({required String topicId, required String author, required String title}) {
    final url = 'https://gf2-bbs.exiliumgf.com/threadInfo?id=${Uri.encodeQueryComponent(topicId)}&hash_flag=1&back_url=%2F';
    return '分享了【$author】帖子:【$title】【$url】来自追放官方社区';
  }

  static String? _positiveId(String? value) {
    if (value == null || !RegExp(r'^\d+$').hasMatch(value)) return null;
    final id = int.tryParse(value);
    return id != null && id > 0 ? id.toString() : null;
  }

  static String? parseId(String input) {
    final text = input.trim().replaceAll('&amp;', '&').replaceAll(r'\&', '&');
    final directId = _positiveId(text);
    if (directId != null) return directId;

    // 仅识别社区帖子链接，避免将普通文本或用户主页中的数字当成帖子。
    final urls = RegExp(r'''https?://[^\s<>"“”【】（）()，。]+''', caseSensitive: false)
        .allMatches(text).map((match) => match.group(0)!).toList();
    if (text.startsWith('gf2-bbs.exiliumgf.com/') || text.startsWith('gf2-bbs.sunborngame.com/')) {
      urls.add('https://$text');
    }
    for (final url in urls) {
      try {
        final uri = Uri.tryParse(url);
        if (uri == null || !['gf2-bbs.exiliumgf.com', 'gf2-bbs.sunborngame.com'].contains(uri.host.toLowerCase())) {
          continue;
        }
        // 兼容旧分享地址及带 # 的路由形式。
        final route = uri.fragment.startsWith('/') ? Uri.parse(uri.fragment) : uri;
        final path = route.path.replaceFirst(RegExp(r'/$'), '').toLowerCase();
        if (!['/threadinfo', '/m/threadinfo', '/share', '/m/share'].contains(path)) continue;
        final id = _positiveId(route.queryParameters['id']);
        if (id != null) return id;
      } on FormatException {
        // 非法链接按普通关键词搜索。
        continue;
      }
    }
    return null;
  }

  /// HTML 的 href 按链接解析，不把相对数字路径或正文锚点当成帖子 ID。
  static String? parseHref(String href) {
    final value = href.trim().replaceAll('&amp;', '&');
    if (value.isEmpty || (value.startsWith('#') && !value.startsWith('#/'))) return null;
    try {
      final uri = Uri.parse('https://gf2-bbs.exiliumgf.com/').resolve(value);
      if (!['http', 'https'].contains(uri.scheme) ||
          !['gf2-bbs.exiliumgf.com', 'gf2-bbs.sunborngame.com'].contains(uri.host.toLowerCase())) {
        return null;
      }
      return parseId(uri.toString());
    } on FormatException {
      return null;
    }
  }
}
