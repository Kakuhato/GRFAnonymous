
///LikeItem
class LikeItem {
  String avatarUrl;
  int commentFloor;
  int commentId;
  int id;
  bool isRead;
  String logTime;
  String title;
  int topicId;

  LikeItem({
    required this.avatarUrl,
    required this.commentFloor,
    required this.commentId,
    required this.id,
    required this.isRead,
    required this.logTime,
    required this.title,
    required this.topicId,
  });

  //下划线命名json
  factory LikeItem.fromJson(Map<String, dynamic> json) {
    return LikeItem(
      avatarUrl: json['avatar_url'],
      commentFloor: json['comment_floor'],
      commentId: json['comment_id'],
      id: json['id'],
      isRead: json['is_read'],
      logTime: json['log_time'],
      title: json['title'],
      topicId: json['topic_id'],
    );
  }

  //不用等号
  Map<String, dynamic> toJson() {
    return {
      'avatar_url': avatarUrl,
      'comment_floor': commentFloor,
      'comment_id': commentId,
      'id': id,
      'is_read': isRead,
      'log_time': logTime,
      'title': title,
      'topic_id': topicId,
    };
  }

}
