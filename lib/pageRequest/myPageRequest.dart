import 'package:grfanonymous/models/userData.dart';
import 'package:grfanonymous/pageRequest/requestUtils.dart';
import 'package:dio/dio.dart';
import 'package:oktoast/oktoast.dart';

import '../models/topicList.dart';

class MyPageRequest {
  ListParams ownTopicListParam = ListParams(
    hotValue: 0,
    lastTid: 0,
    nextPage: true,
    pubTime: 0,
    replyTime: 0,
    total: 0,
    sortType: SortType.reply,
    categoryId: CategoryId.none,
    queryType: QueryType.identity,
  );
  ListParams favorTopicListParam = ListParams(
    // 要用total检测下一页
    hotValue: 0,
    lastTid: 0,
    nextPage: true,
    pubTime: 0,
    replyTime: 0,
    total: 0,
    pageNum: 1,
    sortType: SortType.reply,
    categoryId: CategoryId.none,
    queryType: QueryType.favor,
  );
  ListParams replyListParam = ListParams(
    // 要用nextPage检测下一页
    lastTid: 0,
    nextPage: true,
    pubTime: 0,
    replyTime: 0,
    pageNum: 1,
    createTime: 0,
    sortType: SortType.reply,
    categoryId: CategoryId.none,
    queryType: QueryType.favor,
  );

  bool _isLoading = false;
  late UserData userData = defaultUserData;
  late GameData gameData = defaultGameData;
  List<Topic> ownTopicList = [];
  List<Topic> favorTopicList = [];
  List<MyReply> replyList = [];

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

  Future getOwnTopic({
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
        "sort_type": ownTopicListParam.sortType.type,
        "category_id": ownTopicListParam.categoryId.type,
        "query_type": ownTopicListParam.queryType.type,
        "last_tid": ownTopicListParam.lastTid,
        "pub_time": ownTopicListParam.pubTime,
        "user_id": user_id,
      });
    }
    if (response.data["Code"] == 0 &&
        (response.data['data']['list'] as List).isNotEmpty) {
      var list = response.data['data']['list'] as List;

      ownTopicListParam.lastTid = response.data['data']['last_tid'];
      ownTopicListParam.nextPage = response.data['data']['next_page'];
      ownTopicListParam.pubTime = response.data['data']['pub_time'];
      ownTopicListParam.total = response.data['data']['total'];
      ownTopicListParam.sortType = sort_type;
      ownTopicListParam.categoryId = category_id;
      ownTopicListParam.queryType = query_type;
      if (!onLoad) {
        ownTopicList = list.map((i) => Topic.fromJson(i)).toList();
      } else {
        ownTopicList.addAll(list.map((i) => Topic.fromJson(i)).toList());
      }
    } else {
      ownTopicList = [];
      ownTopicListParam.nextPage = false;
    }
    _isLoading = false;
  }

  Future getFavorTopic({
    bool onFresh = true,
    int userId = 0,
    int pageNum = 1,
    int pageSize = 10,
    SortType sortType = SortType.reply,
    CategoryId categoryId = CategoryId.none,
    QueryType queryType = QueryType.favor,
  }) async {
    if (_isLoading) return;
    _isLoading = true;
    Response response = await DioInstance.instance().get(
      path: "/community/topic/list",
      param: {
        "sort_type": favorTopicListParam.sortType.type,
        "category_id": favorTopicListParam.categoryId.type,
        "query_type": favorTopicListParam.queryType.type,
        "page_num": onFresh ? 1 : favorTopicListParam.pageNum + 1,
        "page_size": pageSize,
        "user_id": userId,
      },
    );
    if (response.data["Code"] == 0 &&
        (response.data['data']['list'] as List).isNotEmpty) {
      if (onFresh) {
        favorTopicList = response.data['data']['list']
            .map<Topic>((item) => Topic.fromJson(item))
            .toList();
        favorTopicListParam.pageNum = 1;
      } else {
        favorTopicList.addAll(response.data['data']['list']
            .map<Topic>((item) => Topic.fromJson(item))
            .toList());
        favorTopicListParam.pageNum++;
      }
      favorTopicListParam.total = response.data['data']['total'];
    } else {
      favorTopicList = [];
    }
    _isLoading = false;
  }

  Future getReply({
    bool onFresh = true,
    int userId = 0,
    int pageNum = 1,
    int pageSize = 10,
    SortType sortType = SortType.reply,
    CategoryId categoryId = CategoryId.none,
    QueryType queryType = QueryType.favor,
  }) async {
    if (_isLoading) return;
    _isLoading = true;
    Response response = await DioInstance.instance().post(
      path: "/community/comment/user_own_list",
      data: {
        "sort_type": replyListParam.sortType.type,
        "category_id": replyListParam.categoryId.type,
        "query_type": replyListParam.queryType.type,
        "page_num": onFresh ? 1 : replyListParam.pageNum + 1,
        "page_size": pageSize,
        "user_id": userId,
        "last_tid": onFresh ? 0 : replyListParam.lastTid,
        "create_time": onFresh ? 0 : replyListParam.createTime,
      },
    );
    if(response.data["Code"] == 0 && response.data['data']['list'].isNotEmpty) {
      if (onFresh) {
        replyList = response.data['data']['list']
            .map<MyReply>((item) => MyReply.fromJson(item))
            .toList();
        replyListParam.pageNum = 1;
        replyListParam.lastTid = response.data['data']['last_tid'];
        replyListParam.createTime = response.data['data']['create_time'];
      } else {
        replyList.addAll(response.data['data']['list']
            .map<MyReply>((item) => MyReply.fromJson(item))
            .toList());
        replyListParam.pageNum++;
        replyListParam.lastTid = response.data['data']['last_tid'];
        replyListParam.createTime = response.data['data']['create_time'];
      }
      replyListParam.nextPage = response.data['data']['next_page'];
    } else {
      replyList = [];
    }
    _isLoading = false;
  }

}
