/// 仅识别官方社区话题详情链接，避免误用其他页面或网站的 id。
class ThemeLink {
  ThemeLink._();

  static int? parseHref(String href) {
    final value = href.trim().replaceAll('&amp;', '&');
    if (value.isEmpty || (value.startsWith('#') && !value.startsWith('#/'))) return null;
    try {
      final uri = Uri.parse('https://gf2-bbs.exiliumgf.com/').resolve(value);
      if (!['http', 'https'].contains(uri.scheme) ||
          !['gf2-bbs.exiliumgf.com', 'gf2-bbs.sunborngame.com'].contains(uri.host.toLowerCase())) {
        return null;
      }
      final route = uri.fragment.startsWith('/') ? Uri.parse(uri.fragment) : uri;
      final path = route.path.replaceFirst(RegExp(r'/$'), '').toLowerCase();
      if (!['/themeinfo', '/m/themeinfo'].contains(path)) return null;
      final idValue = route.queryParameters['id'];
      if (idValue == null || !RegExp(r'^\d+$').hasMatch(idValue)) return null;
      final id = int.tryParse(idValue);
      return id != null && id > 0 ? id : null;
    } on FormatException {
      return null;
    }
  }
}
