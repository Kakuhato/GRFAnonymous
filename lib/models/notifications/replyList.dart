
///ReplyItem
class ReplyItem {
  String avatarUrl;
  int commentFloor;
  int commentId;
  String content;
  int id;
  bool isRead;
  String logTime;
  String title;
  int topicId;

  ReplyItem({
    required this.avatarUrl,
    required this.commentFloor,
    required this.commentId,
    required this.content,
    required this.id,
    required this.isRead,
    required this.logTime,
    required this.title,
    required this.topicId,
  });

  //下划线命名json，content可能为null
  factory ReplyItem.fromJson(Map<String, dynamic> json) {
    return ReplyItem(
      avatarUrl: json['avatar_url'],
      commentFloor: json['comment_floor'],
      commentId: json['comment_id'],
      content: json['content'] ?? "",
      id: json['id'],
      isRead: json['is_read'],
      logTime: json['log_time'],
      title: json['title'],
      topicId: json['topic_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'avatar_url': avatarUrl,
      'comment_floor': commentFloor,
      'comment_id': commentId,
      'content': content,
      'id': id,
      'is_read': isRead,
      'log_time': logTime,
      'title': title,
      'topic_id': topicId,
    };
  }

}
