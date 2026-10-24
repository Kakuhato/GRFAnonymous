class SearchUser {
  const SearchUser({
    required this.uid,
    required this.nickname,
    required this.avatar,
    required this.level,
    required this.isFollow,
  });

  final int uid;
  final String nickname;
  final String avatar;
  final int level;
  final bool isFollow;

  factory SearchUser.fromJson(Map<String, dynamic> json) {
    return SearchUser(
      uid: int.tryParse('${json['uid']}') ?? 0,
      nickname: json['nick_name']?.toString() ?? '',
      avatar: json['avatar']?.toString() ?? '',
      level: int.tryParse('${json['lv']}') ?? 0,
      isFollow: json['is_follow'] == true || json['is_follow'] == 1 || json['is_follow'] == '1',
    );
  }
}
