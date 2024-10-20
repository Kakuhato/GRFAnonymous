
class InfoItem {
  String avatarUrl;
  String content;
  int id;
  bool isRead;
  String logTime;
  String title;
  int userId;

  InfoItem({
    required this.avatarUrl,
    required this.content,
    required this.id,
    required this.isRead,
    required this.logTime,
    required this.title,
    required this.userId,
  });

  //下划线命名json
  factory InfoItem.fromJson(Map<String, dynamic> json) {
    return InfoItem(
      avatarUrl: json['avatar_url'],
      content: json['content'],
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
      'content': content,
      'id': id,
      'is_read': isRead,
      'log_time': logTime,
      'title': title,
      'user_id': userId,
    };
  }

}
