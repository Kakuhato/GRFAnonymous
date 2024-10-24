///WebViewContent
class WebViewContent {
  int authorCommentNum;
  int badNum;
  int categoryId;
  String categoryName;
  int commentNum;
  String content;
  String createTime;
  int declare;
  int favorNum;
  String ipLocation;
  bool isAdmin;
  bool isAuthor;
  bool isBad;
  bool isFavor;
  bool isFollow;
  bool isLike;
  int likeNum;
  List<String> likeUserAvatars;
  List<String> picList;
  List<ThemeInfo> themeInfo;
  String title;
  int topicId;
  String updateTime;
  String userAvatar;
  int userId;
  int userLevel;
  String userNickName;
  String viewNum;

  WebViewContent({
    required this.authorCommentNum,
    required this.badNum,
    required this.categoryId,
    required this.categoryName,
    required this.commentNum,
    required this.content,
    required this.createTime,
    required this.declare,
    required this.favorNum,
    required this.ipLocation,
    required this.isAdmin,
    required this.isAuthor,
    required this.isBad,
    required this.isFavor,
    required this.isFollow,
    required this.isLike,
    required this.likeNum,
    required this.likeUserAvatars,
    required this.picList,
    required this.themeInfo,
    required this.title,
    required this.topicId,
    required this.updateTime,
    required this.userAvatar,
    required this.userId,
    required this.userLevel,
    required this.userNickName,
    required this.viewNum,
  });
  //下划线命名json
  factory WebViewContent.fromJson(Map<String, dynamic> json) {
    return WebViewContent(
      authorCommentNum: json['author_comment_num'],
      badNum: json['bad_num'],
      categoryId: json['category_id'],
      categoryName: json['category_name'],
      commentNum: json['comment_num'],
      content: json['content'],
      createTime: json['create_time'],
      declare: json['declare'],
      favorNum: json['favor_num'],
      ipLocation: json['ip_location'],
      isAdmin: json['is_admin'],
      isAuthor: json['is_author'],
      isBad: json['is_bad'],
      isFavor: json['is_favor'],
      isFollow: json['is_follow'],
      isLike: json['is_like'],
      likeNum: json['like_num'],
      likeUserAvatars: List<String>.from(json['like_user_avatars']),
      picList: List<String>.from(json['pic_list'] ?? []),
      themeInfo: List<ThemeInfo>.from(
          json['theme_info'].map((i) => ThemeInfo.fromJson(i))),
      title: json['title'],
      topicId: json['topic_id'],
      updateTime: json['update_time'],
      userAvatar: json['user_avatar'],
      userId: json['user_id'],
      userLevel: json['user_level'],
      userNickName: json['user_nick_name'],
      viewNum: json['view_num'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'author_comment_num': authorCommentNum,
      'bad_num': badNum,
      'category_id': categoryId,
      'category_name': categoryName,
      'comment_num': commentNum,
      'content': content,
      'create_time': createTime,
      'declare': declare,
      'favor_num': favorNum,
      'ip_location': ipLocation,
      'is_admin': isAdmin,
      'is_author': isAuthor,
      'is_bad': isBad,
      'is_favor': isFavor,
      'is_follow': isFollow,
      'is_like': isLike,
      'like_num': likeNum,
      'like_user_avatars': likeUserAvatars,
      'pic_list': picList,
      'theme_info': themeInfo,
      'title': title,
      'topic_id': topicId,
      'update_time': updateTime,
      'user_avatar': userAvatar,
      'user_id': userId,
      'user_level': userLevel,
      'user_nick_name': userNickName,
      'view_num': viewNum,
    };
  }
}

class ThemeInfo {
  int? id;
  String? name;

  ThemeInfo({
    this.id,
    this.name,
  });

  factory ThemeInfo.fromJson(Map<String, dynamic> json) {
    return ThemeInfo(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
