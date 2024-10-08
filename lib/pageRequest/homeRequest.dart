import 'package:demo/models/BannerItem.dart';
import 'package:demo/models/TopicList.dart';
import 'package:demo/pageRequest/requestUtils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

class HomePageRequest with ChangeNotifier {
  List<BannerItem> bannerList = [];
  List<Topic> topicList = [];
  Dio dio = Dio();
  int hotValue = 0;
  int lastTid = 0;
  bool nextPage = true;
  int pubTime = 0;
  int replyTime = 0;
  int total = 0;
  SortType sortType = SortType.reply;
  CategoryId categoryId = CategoryId.recommend;
  QueryType queryType = QueryType.homepage;

  Future getBanner() async {
    Response response = await DioInstance.instance().get(path: "/community/banner");
    if (response.data != null) {
      var list = response.data['data']['banner_list'] as List;
      bannerList = list.map((i) => BannerItem.fromJson(i)).toList();
    } else {
      bannerList = [];
    }

    notifyListeners();

    // return bannerList;
  }

  Future getTopic({
    SortType sort_type = SortType.reply,
    CategoryId category_id = CategoryId.recommend,
    QueryType query_type = QueryType.homepage,
    int last_tid = 0,
    int pub_time = 0,
    int reply_time = 0,
    int hot_value = 0,
    bool onLoad = false,
  }) async {
    Response response =
        await DioInstance.instance().get(path:  "/community/topic/list", param: {
      "sort_type":  onLoad ? sortType.type : sort_type.type,
      "category_id": onLoad ? categoryId.type : category_id.type,
      "query_type": onLoad ? queryType.type : query_type.type,
      "last_tid": onLoad ? lastTid : last_tid,
      "pub_time": onLoad ? pubTime : pub_time,
      "reply_time": onLoad ? replyTime : reply_time,
      "hot_value": onLoad ? hotValue : hot_value,
    });
    if (response.data != null) {
      // print(response.requestOptions.queryParameters);
      // print(response);
      var list = response.data['data']['list'] as List;

      hotValue = response.data['data']['hot_value'];
      lastTid = response.data['data']['last_tid'];
      nextPage = response.data['data']['next_page'];
      pubTime = response.data['data']['pub_time'];
      replyTime = response.data['data']['reply_time'];
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
    }

    notifyListeners();
  }
}
