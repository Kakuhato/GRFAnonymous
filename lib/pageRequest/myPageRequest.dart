import 'package:grfanonymous/models/userData.dart';
import 'package:grfanonymous/pageRequest/requestUtils.dart';
import 'package:dio/dio.dart';
import 'package:oktoast/oktoast.dart';

import '../models/topicList.dart';

class MyPageRequest {
  int hotValue = 0;
  int lastTid = 0;
  bool nextPage = true;
  int pubTime = 0;
  int replyTime = 0;
  int total = 0;
  SortType sortType = SortType.reply;
  CategoryId categoryId = CategoryId.none;
  QueryType queryType = QueryType.identity;
  bool _isLoading = false;
  late UserData userData = defaultUserData;
  late GameData gameData = defaultGameData;
  List<Topic> topicList = [];

  Future getUserData() async {
    Response response = await DioInstance.instance().post(
      path: "/community/member/info",
      data: {},
    );
    if (response.data != null && response.data['Code'] == 0) {
      userData = UserData.fromJson(response.data['data']['user']);
    } else {
      showToast("用户信息获取失败");
    }
  }

  Future getGameData() async {
    Response response = await DioInstance.instance().post(
      path: "/community/game/info",
      data: {},
    );
    if (response.data != null && response.data['Code'] == 0) {
      gameData = GameData.fromJson(response.data['data']);
    } else {
      showToast("游戏信息获取失败");
    }
  }

  Future getOtherUserData(String uid) async {
    Response response = await DioInstance.instance().post(
      path: "/community/member/info",
      data: {
        "uid": int.parse(uid),
      },
    );
    if (response.data != null && response.data['Code'] == 0) {
      userData = UserData.fromJson(response.data['data']['user']);
    } else {
      showToast("用户信息获取失败");
    }
  }

  Future getOtherGameData(String uid) async {
    Response response = await DioInstance.instance().post(
      path: "/community/game/info",
      data: {
        "uid": int.parse(uid),
      },
    );
    if (response.data != null && response.data['Code'] == 0) {
      gameData = GameData.fromJson(response.data['data']);
    } else {
      showToast("用户信息获取失败");
    }
  }

  Future getTopic({
    SortType sort_type = SortType.reply,
    CategoryId category_id = CategoryId.none,
    QueryType query_type = QueryType.identity,
    int last_tid = 0,
    int pub_time = 0,
    int reply_time = 0,
    int hot_value = 0,
    int user_id = 0,
    bool onLoad = false,
  }) async {
    if (_isLoading) return;
    _isLoading = true;
    Response response;
    if (onLoad == false) {
      response = await DioInstance.instance()
          .get(path: "/community/topic/list", param: {
        "sort_type": sort_type.type,
        "category_id": category_id.type,
        "query_type": query_type.type,
        "last_tid": last_tid,
        "pub_time": pub_time,
        "reply_time": reply_time,
        "hot_value": hot_value,
        "user_id": user_id,
      });
    } else {
      response = await DioInstance.instance()
          .get(path: "/community/topic/list", param: {
        "sort_type": sortType.type,
        "category_id": categoryId.type,
        "query_type": queryType.type,
        "last_tid": lastTid,
        "pub_time": pubTime,
        "user_id": user_id,
      });
    }
    if (response.data["Code"] == 0 && (response.data['data']['list'] as List).isNotEmpty) {
      var list = response.data['data']['list'] as List;

      lastTid = response.data['data']['last_tid'];
      nextPage = response.data['data']['next_page'];
      pubTime = response.data['data']['pub_time'];
      total = response.data['data']['total'];
      sortType = sort_type;
      categoryId = category_id;
      queryType = query_type;
      if (!onLoad) {
        topicList = list.map((i) => Topic.fromJson(i)).toList();
      } else {
        topicList.addAll(list.map((i) => Topic.fromJson(i)).toList());
      }
    } else {
      topicList = [];
      nextPage = false;
    }
    _isLoading = false;

  }
}
