//这个可以不用
class ReplyList {
  int hotValue;
  int lastId;
  List<SingleComment> list;
  bool nextPage;

  ReplyList({
    required this.hotValue,
    required this.lastId,
    required this.list,
    required this.nextPage,
  });
}

class SingleComment {
  int commentId;
  List<CommentReply> commentReply;
  String content;
  String createTime;
  int dislikeNum;
  int floorNum;
  String ipLocation;
  bool isAdmin;
  bool isAuthor;
  bool isCommentAuthor;
  bool isDislike;
  bool isLike;
  int likeNum;
  dynamic picList;
  int replyNum;
  String userAvatar;
  int userId;
  int userLevel;
  String userNickName;

  //可能没有commentReply字段
  SingleComment({
    required this.commentId,
    required this.commentReply,
    required this.content,
    required this.createTime,
    required this.dislikeNum,
    required this.floorNum,
    required this.ipLocation,
    required this.isAdmin,
    required this.isAuthor,
    required this.isCommentAuthor,
    required this.isDislike,
    required this.isLike,
    required this.likeNum,
    required this.picList,
    required this.replyNum,
    required this.userAvatar,
    required this.userId,
    required this.userLevel,
    required this.userNickName,
  });

  //用下划线命名json参数,其中picList为String列表但可能为null，commentReply也可能为null
  factory SingleComment.fromJson(Map<String, dynamic> json) {
    return SingleComment(
      commentId: json['comment_id'],
      commentReply: json['comment_reply'] != null
          ? List<CommentReply>.from(
              json['comment_reply'].map((i) => CommentReply.fromJson(i)))
          : [],
      content: json['content'],
      createTime: json['create_time'],
      dislikeNum: json['dislike_num'],
      floorNum: json['floor_num'],
      ipLocation: json['ip_location'],
      isAdmin: json['is_admin'],
      isAuthor: json['is_author'],
      isCommentAuthor: json['is_comment_author'],
      isDislike: json['is_dislike'],
      isLike: json['is_like'],
      likeNum: json['like_num'],
      picList: json['pic_list'],
      replyNum: json['reply_num'],
      userAvatar: json['user_avatar'],
      userId: json['user_id'],
      userLevel: json['user_level'],
      userNickName: json['user_nick_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'comment_id': commentId,
      'comment_reply': commentReply,
      'content': content,
      'create_time': createTime,
      'dislike_num': dislikeNum,
      'floor_num': floorNum,
      'ip_location': ipLocation,
      'is_admin': isAdmin,
      'is_author': isAuthor,
      'is_comment_author': isCommentAuthor,
      'is_dislike': isDislike,
      'is_like': isLike,
      'like_num': likeNum,
      'pic_list': picList,
      'reply_num': replyNum,
      'user_avatar': userAvatar,
      'user_id': userId,
      'user_level': userLevel,
      'user_nick_name': userNickName,
    };
  }
}

class CommentReply {
  int commentId;
  String content;
  String createTime;
  int dislikeNum;
  int floorNum;
  String ipLocation;
  bool isAdmin;
  bool isAuthor;
  bool isCommentAuthor;
  bool isDislike;
  bool isLike;
  bool? isTopicAuthor;
  int likeNum;
  dynamic picList;
  int replyNum;
  String? replyTo;
  int? replyToUid;
  String userAvatar;
  int userId;
  int userLevel;
  String userNickName;

  CommentReply({
    required this.commentId,
    required this.content,
    required this.createTime,
    required this.dislikeNum,
    required this.floorNum,
    required this.ipLocation,
    required this.isAdmin,
    required this.isAuthor,
    required this.isCommentAuthor,
    required this.isDislike,
    required this.isLike,
    this.isTopicAuthor,
    required this.likeNum,
    required this.picList,
    required this.replyNum,
    this.replyTo,
    this.replyToUid,
    required this.userAvatar,
    required this.userId,
    required this.userLevel,
    required this.userNickName,
  });

  //用下划线命名json参数，其中picList为String列表但可能为null
  factory CommentReply.fromJson(Map<String, dynamic> json) {
    return CommentReply(
      commentId: json['comment_id'],
      content: json['content'],
      createTime: json['create_time'],
      dislikeNum: json['dislike_num'],
      floorNum: json['floor_num'],
      ipLocation: json['ip_location'],
      isAdmin: json['is_admin'],
      isAuthor: json['is_author'],
      isCommentAuthor: json['is_comment_author'],
      isDislike: json['is_dislike'],
      isLike: json['is_like'],
      isTopicAuthor: json['is_topic_author'],
      likeNum: json['like_num'],
      picList: json['pic_list'],
      replyNum: json['reply_num'],
      replyTo: json['reply_to'],
      replyToUid: json['reply_to_uid'],
      userAvatar: json['user_avatar'],
      userId: json['user_id'],
      userLevel: json['user_level'],
      userNickName: json['user_nick_name'],
    );
  }

  //用下划线命名json参数
  Map<String, dynamic> toJson() {
    return {
      'comment_id': commentId,
      'content': content,
      'create_time': createTime,
      'dislike_num': dislikeNum,
      'floor_num': floorNum,
      'ip_location': ipLocation,
      'is_admin': isAdmin,
      'is_author': isAuthor,
      'is_comment_author': isCommentAuthor,
      'is_dislike': isDislike,
      'is_like': isLike,
      'is_topic_author': isTopicAuthor,
      'like_num': likeNum,
      'pic_list': picList,
      'reply_num': replyNum,
      'reply_to': replyTo,
      'reply_to_uid': replyToUid,
      'user_avatar': userAvatar,
      'user_id': userId,
      'user_level': userLevel,
      'user_nick_name': userNickName,
    };
  }
}
