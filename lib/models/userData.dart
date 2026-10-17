import '../pageRequest/requestUtils.dart';

///UserData
class UserData {
  int authLock;
  int authType;
  String avatar;
  int exp;
  int fans;
  int favors;
  int follows;
  int gameCommanderLevel;
  String gameNickName;
  int gameUid;
  String ipLocation;
  bool isAdmin;
  bool isAuthor;
  bool isFollow;
  int level;
  String likes;
  int nextLvExp;
  String nickName;
  int score;
  bool showFans;
  bool showFavor;
  bool showFollow;
  bool showGame;
  String signature;
  int uid;
  int? _endlessFloor;
  int? _endlessRank;

  int get endlessFloor => _endlessFloor ?? 0;
  int get endlessRank => _endlessRank ?? 0;

  UserData({
    required this.authLock,
    required this.authType,
    required this.avatar,
    required this.exp,
    required this.fans,
    required this.favors,
    required this.follows,
    required this.gameCommanderLevel,
    required this.gameNickName,
    required this.gameUid,
    required this.ipLocation,
    required this.isAdmin,
    required this.isAuthor,
    required this.isFollow,
    required this.level,
    required this.likes,
    required this.nextLvExp,
    required this.nickName,
    required this.score,
    required this.showFans,
    required this.showFavor,
    required this.showFollow,
    required this.showGame,
    required this.signature,
    required this.uid,
    int endlessFloor = 0,
    int endlessRank = 0,
  }) : _endlessFloor = endlessFloor,
       _endlessRank = endlessRank;

  //下划线命名json
  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      authLock: json['auth_lock'],
      authType: json['auth_type'],
      avatar: json['avatar'],
      exp: json['exp'],
      fans: json['fans'],
      favors: json['favors'],
      follows: json['follows'],
      gameCommanderLevel: json['game_commander_level'],
      gameNickName: json['game_nick_name'],
      gameUid: json['game_uid'],
      ipLocation: json['ip_location'],
      isAdmin: json['is_admin'],
      isAuthor: json['is_author'],
      isFollow: json['is_follow'],
      level: json['level'],
      likes: json['likes'].toString(),
      nextLvExp: json['next_lv_exp'],
      nickName: json['nick_name'],
      score: json['score'],
      showFans: json['show_fans'],
      showFavor: json['show_favor'],
      showFollow: json['show_follow'],
      showGame: json['show_game'],
      signature: json['signature'],
      uid: json['uid'],
      endlessFloor: int.tryParse('${json['endless_floor']}') ?? 0,
      endlessRank: int.tryParse('${json['endless_rank']}') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'auth_lock': authLock,
      'auth_type': authType,
      'avatar': avatar,
      'exp': exp,
      'fans': fans,
      'favors': favors,
      'follows': follows,
      'game_commander_level': gameCommanderLevel,
      'game_nick_name': gameNickName,
      'game_uid': gameUid,
      'ip_location': ipLocation,
      'is_admin': isAdmin,
      'is_author': isAuthor,
      'is_follow': isFollow,
      'level': level,
      'likes': likes,
      'next_lv_exp': nextLvExp,
      'nick_name': nickName,
      'score': score,
      'show_fans': showFans,
      'show_favor': showFavor,
      'show_follow': showFollow,
      'show_game': showGame,
      'signature': signature,
      'uid': uid,
      'endless_floor': endlessFloor,
      'endless_rank': endlessRank,
    };
  }
}

///GameData
class GameData {
  BaseInfo baseInfo;
  List<HeroList> heroList;
  StageInfo stageInfo;
  List<ThemeInfo> themeInfo;
  UserInfo userInfo;

  GameData({
    required this.baseInfo,
    required this.heroList,
    required this.stageInfo,
    required this.themeInfo,
    required this.userInfo,
  });

  //下划线命名json，baseInfo,heroList,stageInfo,themeInfo,userInfo均可能返回空
  factory GameData.fromJson(Map<String, dynamic> json) {
    return GameData(
      baseInfo: BaseInfo.fromJson(json['base_info'] ?? {}),
      heroList: (json['hero_list'] as List?)
              ?.map((i) => HeroList.fromJson(i))
              .toList() ??
          [],
      stageInfo: StageInfo.fromJson(json['stage_info'] ?? {}),
      themeInfo: (json['theme_info'] as List?)
              ?.map((i) => ThemeInfo.fromJson(i))
              .toList() ??
          [],
      userInfo: UserInfo.fromJson(json['user_info'] ?? {}),
    );
  }

  // factory GameData.fromJson(Map<String, dynamic> json) {
  //   return GameData(
  //     baseInfo: BaseInfo.fromJson(json['base_info']),
  //     heroList:
  //         (json['hero_list'] as List).map((i) => HeroList.fromJson(i)).toList(),
  //     stageInfo: StageInfo.fromJson(json['stage_info']),
  //     themeInfo: (json['theme_info'] as List)
  //         .map((i) => ThemeInfo.fromJson(i))
  //         .toList(),
  //     userInfo: UserInfo.fromJson(json['user_info']),
  //   );
  // }

  Map<String, dynamic> toJson() {
    return {
      'base_info': baseInfo.toJson(),
      'hero_list': heroList.map((i) => i.toJson()).toList(),
      'stage_info': stageInfo.toJson(),
      'theme_info': themeInfo.map((i) => i.toJson()).toList(),
      'user_info': userInfo.toJson(),
    };
  }
}

class BaseInfo {
  int achievementCount;
  int activeDays;
  int heroCount;
  String mainStage;
  int skinCount;
  int weaponCount;

  BaseInfo({
    required this.achievementCount,
    required this.activeDays,
    required this.heroCount,
    required this.mainStage,
    required this.skinCount,
    required this.weaponCount,
  });

  //下划线命名json，可能传入{}
  factory BaseInfo.fromJson(Map<String, dynamic> json) {
    return BaseInfo(
      achievementCount: json['achievement_count'] ?? -1,
      activeDays: json['active_days'] ?? -1,
      heroCount: json['hero_count'] ?? -1,
      mainStage: json['main_stage'] ?? "-",
      skinCount: json['skin_count'] ?? 0,
      weaponCount: json['weapon_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'achievement_count': achievementCount,
      'active_days': activeDays,
      'hero_count': heroCount,
      'main_stage': mainStage,
      'skin_count': skinCount,
      'weapon_count': weaponCount,
    };
  }
}

class HeroList {
  int duty;
  int? _grade;

  int get grade => _grade ?? 0;
  int id;
  int lv;
  String name;
  int rank;
  int serialId;
  String showPic;
  String skin;

  HeroList({
    required this.duty,
    required this.id,
    required this.lv,
    required this.name,
    required this.rank,
    required this.serialId,
    required this.showPic,
    required this.skin,
    int grade = 0,
  }) : _grade = grade;

  //下划线命名json，可能传入{
  factory HeroList.fromJson(Map<String, dynamic> json) {
    return HeroList(
      duty: json['duty'] ?? 0,
      grade: int.tryParse('${json['grade']}') ?? 0,
      id: json['id'] ?? 0,
      lv: json['lv'] ?? 0,
      name: json['name'] ?? "",
      rank: json['rank'] ?? 0,
      serialId: json['serial_id'] ?? 0,
      showPic: json['show_pic'] ?? "",
      skin: json['skin'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'duty': duty,
      'grade': grade,
      'id': id,
      'lv': lv,
      'name': name,
      'rank': rank,
      'serial_id': serialId,
      'show_pic': showPic,
      'skin': skin,
    };
  }
}

class GameStageEntry {
  final String key;
  final String name;
  final String image;
  final String detail;

  const GameStageEntry(this.key, this.name, this.image, this.detail);

  factory GameStageEntry.fromJson(String key, Map<String, dynamic> json) {
    final parts = <String>[
      if ('${json['stage_name'] ?? ''}'.isNotEmpty) '${json['stage_name']}',
      if ('${json['stage_code'] ?? ''}'.isNotEmpty) '${json['stage_code']}',
      if (json['complete_percent'] != null)
        // 此字段在无尽模式中为层数，在部分玩法中为积分，并非均为百分比。
        '${json['complete_percent']}${key == 'tower_stage' ? '%' : key == 'endless_tower' ? '层' : ''}',
      if (json['max_score'] != null) '最高分：${json['max_score']}',
    ];
    return GameStageEntry(key, '${json['name'] ?? ''}',
        '${json['show_pic'] ?? ''}', parts.join(' · '));
  }
}

class StageInfo {
  KuobianStage kuobianStage;
  TowerStage towerStage;
  WeekCommon weekCommon;
  List<WeekSpecial> weekSpecial;
  Map<String, dynamic>? _rawStages;

  List<GameStageEntry> get entries {
    final result = <GameStageEntry>[];
    for (final entry in (_rawStages ?? <String, dynamic>{}).entries) {
      final values = entry.value is List ? entry.value as List : [entry.value];
      for (final value in values) {
        if (value is Map<String, dynamic> && value.isNotEmpty) {
          result.add(GameStageEntry.fromJson(entry.key, value));
        }
      }
    }
    return result;
  }

  StageInfo({
    required this.kuobianStage,
    required this.towerStage,
    required this.weekCommon,
    required this.weekSpecial,
    Map<String, dynamic>? rawStages,
  }) : _rawStages = rawStages;

  //下划线命名json，可能传入{}，传入weekSpecial的可能为null,json['week_special'] as List可能为null
  factory StageInfo.fromJson(Map<String, dynamic> json) {
    return StageInfo(
      rawStages: Map<String, dynamic>.from(json),
      kuobianStage: KuobianStage.fromJson(json['kuobian_stage'] ?? {}),
      towerStage: TowerStage.fromJson(json['tower_stage'] ?? {}),
      weekCommon: WeekCommon.fromJson(json['week_common'] ?? {}),
      weekSpecial: (json['week_special'] as List?)
              ?.map((i) => WeekSpecial.fromJson(i))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      ...?_rawStages,
      'kuobian_stage': kuobianStage.toJson(),
      'tower_stage': towerStage.toJson(),
      'week_common': weekCommon.toJson(),
      'week_special': weekSpecial.map((i) => i.toJson()).toList(),
    };
  }
}

class KuobianStage {
  int caseId;
  String name;
  String showPic;
  String stageCode;
  String stageName;
  int stayStage;

  KuobianStage({
    required this.caseId,
    required this.name,
    required this.showPic,
    required this.stageCode,
    required this.stageName,
    required this.stayStage,
  });

  //下划线命名json，可能传入{}，传入{}返回null
  factory KuobianStage.fromJson(Map<String, dynamic> json) {
    return KuobianStage(
      caseId: json['case_id'] ?? 0,
      name: json['name'] ?? "",
      showPic: json['show_pic'] ?? "",
      stageCode: json['stage_code'] ?? "",
      stageName: json['stage_name'] ?? "",
      stayStage: json['stay_stage'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'case_id': caseId,
      'name': name,
      'show_pic': showPic,
      'stage_code': stageCode,
      'stage_name': stageName,
      'stay_stage': stayStage,
    };
  }
}

class TowerStage {
  int caseId;
  int completePercent;
  String name;
  String showPic;
  String stageCode;
  String stageName;
  int stayStage;

  TowerStage({
    required this.caseId,
    required this.completePercent,
    required this.name,
    required this.showPic,
    required this.stageCode,
    required this.stageName,
    required this.stayStage,
  });

  //下划线命名json，可能传入{}
  factory TowerStage.fromJson(Map<String, dynamic> json) {
    return TowerStage(
      caseId: json['case_id'] ?? 0,
      completePercent: json['complete_percent'] ?? 0,
      name: json['name'] ?? "",
      showPic: json['show_pic'] ?? "",
      stageCode: json['stage_code'] ?? "",
      stageName: json['stage_name'] ?? "",
      stayStage: json['stay_stage'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'case_id': caseId,
      'complete_percent': completePercent,
      'name': name,
      'show_pic': showPic,
      'stage_code': stageCode,
      'stage_name': stageName,
      'stay_stage': stayStage,
    };
  }
}

class WeekCommon {
  int maxScore;
  String name;
  String showPic;
  int stageRank;

  WeekCommon({
    required this.maxScore,
    required this.name,
    required this.showPic,
    required this.stageRank,
  });

  //下划线命名json，可能传入{
  factory WeekCommon.fromJson(Map<String, dynamic> json) {
    return WeekCommon(
      maxScore: json['max_score'] ?? 0,
      name: json['name'] ?? "",
      showPic: json['show_pic'] ?? "",
      stageRank: json['stage_rank'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'max_score': maxScore,
      'name': name,
      'show_pic': showPic,
      'stage_rank': stageRank,
    };
  }
}

class WeekSpecial {
  int caseId;
  String name;
  String showPic;
  String stageCode;
  String stageName;
  int stayStage;

  WeekSpecial({
    required this.caseId,
    required this.name,
    required this.showPic,
    required this.stageCode,
    required this.stageName,
    required this.stayStage,
  });

  //下划线命名json，可能传入{
  factory WeekSpecial.fromJson(Map<String, dynamic> json) {
    return WeekSpecial(
      caseId: json['case_id'] ?? 0,
      name: json['name'] ?? "",
      showPic: json['show_pic'] ?? "",
      stageCode: json['stage_code'] ?? "",
      stageName: json['stage_name'] ?? "",
      stayStage: json['stay_stage'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'case_id': caseId,
      'name': name,
      'show_pic': showPic,
      'stage_code': stageCode,
      'stage_name': stageName,
      'stay_stage': stayStage,
    };
  }
}

class ThemeInfo {
  int caseId;
  int completePercent;
  String showPic;

  ThemeInfo({
    required this.caseId,
    required this.completePercent,
    required this.showPic,
  });

  //下划线命名json，可能传入{}
  factory ThemeInfo.fromJson(Map<String, dynamic> json) {
    return ThemeInfo(
      caseId: json['case_id'] ?? 0,
      completePercent: json['complete_percent'] ?? 0,
      showPic: json['show_pic'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'case_id': caseId,
      'complete_percent': completePercent,
      'show_pic': showPic,
    };
  }
}

class UserInfo {
  String avatar;
  int gameUid;
  String guildName;
  int level;
  String nickName;
  bool showBase;
  bool showHero;
  bool showStage;
  bool showTheme;

  UserInfo({
    required this.avatar,
    required this.gameUid,
    required this.guildName,
    required this.level,
    required this.nickName,
    required this.showBase,
    required this.showHero,
    required this.showStage,
    required this.showTheme,
  });
  //下划线命名json，可能传入{}
  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      avatar: json['avatar'] ?? "",
      gameUid: json['game_uid'] ?? 0,
      guildName: json['guild_name'] ?? "",
      level: json['level'] ?? 0,
      nickName: json['nick_name'] ?? "",
      showBase: json['show_base'] ?? false,
      showHero: json['show_hero'] ?? false,
      showStage: json['show_stage'] ?? false,
      showTheme: json['show_theme'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'avatar': avatar,
      'game_uid': gameUid,
      'guild_name': guildName,
      'level': level,
      'nick_name': nickName,
      'show_base': showBase,
      'show_hero': showHero,
      'show_stage': showStage,
      'show_theme': showTheme,
    };
  }
}

UserData defaultUserData = UserData(
  authLock: 0,
  authType: 0,
  avatar: "",
  exp: 0,
  fans: 0,
  favors: 0,
  follows: 0,
  gameCommanderLevel: 0,
  gameNickName: "",
  gameUid: 0,
  ipLocation: "",
  isAdmin: false,
  isAuthor: false,
  isFollow: false,
  level: 0,
  likes: "0",
  nextLvExp: 0,
  nickName: "",
  score: 0,
  showFans: false,
  showFavor: false,
  showFollow: false,
  showGame: false,
  signature: "",
  uid: 0,
);

GameData defaultGameData = GameData(
  baseInfo: BaseInfo(
    achievementCount: 0,
    activeDays: 0,
    heroCount: 0,
    mainStage: "",
    skinCount: 0,
    weaponCount: 0,
  ),
  heroList: [],
  stageInfo: StageInfo(
    kuobianStage: KuobianStage(
      caseId: 0,
      name: "",
      showPic: "",
      stageCode: "",
      stageName: "",
      stayStage: 0,
    ),
    towerStage: TowerStage(
      caseId: 0,
      completePercent: 0,
      name: "",
      showPic: "",
      stageCode: "",
      stageName: "",
      stayStage: 0,
    ),
    weekCommon: WeekCommon(
      maxScore: 0,
      name: "",
      showPic: "",
      stageRank: 0,
    ),
    weekSpecial: [],
  ),
  themeInfo: [],
  userInfo: UserInfo(
    avatar: "",
    gameUid: 0,
    guildName: "",
    level: 0,
    nickName: "",
    showBase: false,
    showHero: false,
    showStage: false,
    showTheme: false,
  ),
);

class ListParams{
  int hotValue = 0;
  int lastTid = 0;
  bool nextPage = true;
  int pubTime = 0;
  int replyTime = 0;
  int total = 0;
  int pageNum = 0;
  int createTime = 0;
  SortType sortType = SortType.reply;
  CategoryId categoryId = CategoryId.none;
  QueryType queryType = QueryType.identity;

  ListParams({
    this.hotValue = 0,
    this.lastTid = 0,
    this.nextPage = true,
    this.pubTime = 0,
    this.replyTime = 0,
    this.total = 0,
    this.pageNum = 0,
    this.createTime = 0,
    this.sortType = SortType.reply,
    this.categoryId = CategoryId.none,
    this.queryType = QueryType.identity,
  });

}

class MyReply {
  String content;
  String createTime;
  String title;
  int topicId;

  MyReply({
    required this.content,
    required this.createTime,
    required this.title,
    required this.topicId,
  });

  //下划线命名json
  factory MyReply.fromJson(Map<String, dynamic> json) {
    return MyReply(
      content: json['content'],
      createTime: json['create_time'],
      title: json['title'],
      topicId: json['topic_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'create_time': createTime,
      'title': title,
      'topic_id': topicId,
    };
  }

}
