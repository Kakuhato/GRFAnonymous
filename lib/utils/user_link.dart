/// 仅识别官方社区用户主页链接，不把其他网站的 id 当成社区 UID。
class UserLink {
  UserLink._();

  static String? parseHref(String href) {
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
      if (!['/user', '/m/user'].contains(path)) return null;
      final idValue = route.queryParameters['id'];
      if (idValue == null || !RegExp(r'^\d+$').hasMatch(idValue)) return null;
      final uid = int.tryParse(idValue);
      return uid != null && uid > 0 ? uid.toString() : null;
    } on FormatException {
      return null;
    }
  }
}
