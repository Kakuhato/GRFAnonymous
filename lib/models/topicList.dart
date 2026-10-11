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
  // 热重载可能保留新增字段尚未初始化的旧实例，读取时统一兜底。
  String? _coverPic;
  String? _beginTime;
  String? _endTime;
  String get coverPic => _coverPic ?? '';
  String get beginTime => _beginTime ?? '';
  String get endTime => _endTime ?? '';
  String? _avatarFrame;
  String? _userTitle;
  bool? _vip;
  int? _endlessFloor;
  int? _endlessRank;

  String get avatarFrame => _avatarFrame ?? '';
  set avatarFrame(String value) => _avatarFrame = value;

  String get userTitle => _userTitle ?? '';
  set userTitle(String value) => _userTitle = value;

  bool get vip => _vip ?? false;
  set vip(bool value) => _vip = value;

  int get endlessFloor => _endlessFloor ?? 0;
  set endlessFloor(int value) => _endlessFloor = value;

  int get endlessRank => _endlessRank ?? 0;
  set endlessRank(int value) => _endlessRank = value;

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
    String coverPic = '',
    String beginTime = '',
    String endTime = '',
    String avatarFrame = '',
    String userTitle = '',
    bool vip = false,
    int endlessFloor = 0,
    int endlessRank = 0,
  })  : _coverPic = coverPic,
        _beginTime = beginTime,
        _endTime = endTime,
        _avatarFrame = avatarFrame,
        _userTitle = userTitle,
        _vip = vip,
        _endlessFloor = endlessFloor,
        _endlessRank = endlessRank;

  //用下划线命名json参数，其中picList可能为空
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
      picList:
          json['pic_list'] != null ? List<String>.from(json['pic_list']) : [],
      themeInfo: List<ThemeInfo>.from(
          (json['theme_info'] as List? ?? [])
              .map((x) => ThemeInfo.fromJson(x))),
      title: json['title'],
      topicId: json['topic_id'],
      userAvatar: json['user_avatar'],
      userId: json['user_id'],
      userLevel: json['user_level'],
      userNickName: json['user_nick_name'],
      coverPic: json['cover_pic']?.toString() ?? '',
      beginTime: json['begin_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
      avatarFrame: json['avatar_frame'] as String? ?? '',
      userTitle: json['user_title'] as String? ?? '',
      vip: json['vip'] == true || json['vip'] == 1 || json['vip'] == '1',
      endlessFloor: int.tryParse('${json['endless_floor']}') ?? 0,
      endlessRank: int.tryParse('${json['endless_rank']}') ?? 0,
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
      'cover_pic': coverPic,
      'begin_time': beginTime,
      'end_time': endTime,
      'avatar_frame': avatarFrame,
      'user_title': userTitle,
      'vip': vip,
      'endless_floor': endlessFloor,
      'endless_rank': endlessRank,
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
