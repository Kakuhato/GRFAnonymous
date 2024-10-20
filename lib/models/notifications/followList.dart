

///FollowItem
class FollowItem {
  String avatarUrl;
  int id;
  bool isRead;
  String logTime;
  String title;
  int userId;

  FollowItem({
    required this.avatarUrl,
    required this.id,
    required this.isRead,
    required this.logTime,
    required this.title,
    required this.userId,
  });

  // 下划线命名json
  factory FollowItem.fromJson(Map<String, dynamic> json) {
    return FollowItem(
      avatarUrl: json['avatar_url'],
      id: json['id'],
      isRead: json['is_read'],
      logTime: json['log_time'],
      title: json['title'],
      userId: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'avatar_url': avatarUrl,
      'id': id,
      'is_read': isRead,
      'log_time': logTime,
      'title': title,
      'user_id': userId,
    };
  }


}
