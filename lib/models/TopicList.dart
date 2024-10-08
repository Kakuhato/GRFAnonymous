///TopicList
class TopicList {
  int hotValue;
  int lastTid;
  List<Topic> list;
  bool nextPage;
  int pubTime;
  int replyTime;
  int total;

  TopicList({
    required this.hotValue,
    required this.lastTid,
    required this.list,
    required this.nextPage,
    required this.pubTime,
    required this.replyTime,
    required this.total,
  });

//用下划线命名json参数
  factory TopicList.fromJson(Map<String, dynamic> json) {
    return TopicList(
      hotValue: json['hot_value'],
      lastTid: json['last_tid'],
      list: List<Topic>.from(json['list'].map((x) => Topic.fromJson(x))),
      nextPage: json['next_page'],
      pubTime: json['pub_time'],
      replyTime: json['reply_time'],
      total: json['total'],
    );
  }

  //用下划线命名json参数
  Map<String, dynamic> toJson() {
    return {
      'hot_value': hotValue,
      'last_tid': lastTid,
      'list': list.map((x) => x.toJson()).toList(),
      'next_page': nextPage,
      'pub_time': pubTime,
      'reply_time': replyTime,
      'total': total,
    };
  }
}

class Topic {
  int categoryId;
  String categoryName;
  int commentNum;
  String content;
  String createTime;
  bool isAdmin;
  bool isAuthor;
  bool isFavor;
  bool isFollow;
  bool isLike;
  int likeNum;
  List<String> picList;
  List<ThemeInfo> themeInfo;
  String title;
  int topicId;
  String userAvatar;
  int userId;
  int userLevel;
  String userNickName;

  Topic({
    required this.categoryId,
    required this.categoryName,
    required this.commentNum,
    required this.content,
    required this.createTime,
    required this.isAdmin,
    required this.isAuthor,
    required this.isFavor,
    required this.isFollow,
    required this.isLike,
    required this.likeNum,
    required this.picList,
    required this.themeInfo,
    required this.title,
    required this.topicId,
    required this.userAvatar,
    required this.userId,
    required this.userLevel,
    required this.userNickName,
  });

  //用下划线命名json参数
  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      categoryId: json['category_id'],
      categoryName: json['category_name'],
      commentNum: json['comment_num'],
      content: json['content'],
      createTime: json['create_time'],
      isAdmin: json['is_admin'],
      isAuthor: json['is_author'],
      isFavor: json['is_favor'],
      isFollow: json['is_follow'],
      isLike: json['is_like'],
      likeNum: json['like_num'],
      picList: List<String>.from(json['pic_list']),
      themeInfo: List<ThemeInfo>.from(json['theme_info'].map((x) => ThemeInfo.fromJson(x))),
      title: json['title'],
      topicId: json['topic_id'],
      userAvatar: json['user_avatar'],
      userId: json['user_id'],
      userLevel: json['user_level'],
      userNickName: json['user_nick_name'],
    );
  }

//用下划线命名json参数
  Map<String, dynamic> toJson() {
    return {
      'category_id': categoryId,
      'category_name': categoryName,
      'comment_num': commentNum,
      'content': content,
      'create_time': createTime,
      'is_admin': isAdmin,
      'is_author': isAuthor,
      'is_favor': isFavor,
      'is_follow': isFollow,
      'is_like': isLike,
      'like_num': likeNum,
      'pic_list': picList,
      'theme_info': themeInfo,
      'title': title,
      'topic_id': topicId,
      'user_avatar': userAvatar,
      'user_id': userId,
      'user_level': userLevel,
      'user_nick_name': userNickName,
    };
  }

  //用下划线命名json参数
  @override
  String toString() {
    return 'ListElement(categoryId: $categoryId, categoryName: $categoryName, commentNum: $commentNum, content: $content, createTime: $createTime, isAdmin: $isAdmin, isAuthor: $isAuthor, isFavor: $isFavor, isFollow: $isFollow, isLike: $isLike, likeNum: $likeNum, picList: $picList, themeInfo: $themeInfo, title: $title, topicId: $topicId, userAvatar: $userAvatar, userId: $userId, userLevel: $userLevel, userNickName: $userNickName)';
  }

}

class ThemeInfo {
  int themeId;
  String themeName;

  ThemeInfo({
    required this.themeId,
    required this.themeName,
  });

  //用下划线命名json参数
  factory ThemeInfo.fromJson(Map<String, dynamic> json) {
    return ThemeInfo(
      themeId: json['id'],
      themeName: json['name'],
    );
  }

  //用下划线命名json参数
  Map<String, dynamic> toJson() {
    return {
      'id': themeId,
      'name': themeName,
    };
  }

  //用下划线命名json参数
  @override
  String toString() => 'ThemeInfo(themeId: $themeId, themeName: $themeName)';
}