import 'package:demo/models/BannerItem.dart';
import 'package:demo/models/TopicList.dart';
import 'package:demo/pageRequest/requestUtil.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

class HomePageRequest with ChangeNotifier {
  List<BannerItem> bannerList = [];
  List<Topic> topicList = [];
  Dio dio = Dio();

  void initDio(){
    dio.options = BaseOptions(
      method: "GET",
      baseUrl: "https://gf2-bbs-api.sunborngame.com/",
      connectTimeout: Duration(seconds: 30),
      receiveTimeout: Duration(seconds: 30),
      sendTimeout: Duration(seconds: 30),
    );
  }

  Future getBanner() async {


    Response response = await dio.get(
      "/community/banner",
      // queryParameters: {
      //   "game_id": 2,
      //   "platform": 1,
      //   "version": "1.0.0",
      // }
    );
    if (response.data != null) {
      var list = response.data['data']['banner_list'] as List;
      bannerList = list.map((i) => BannerItem.fromJson(i)).toList();
    } else {
      bannerList = [];
    }

    notifyListeners();

    // return bannerList;
  }

  Future getTopic(
    SortType sort_type,
    CategoryId category_id,
    QueryType query_type, {
    int last_tid = 0,
    int pub_time = 0,
    int reply_time = 0,
    int hot_value = 0,
  }) async {
    Response response =
        await dio.get("/community/topic/list", queryParameters: {
      "sort_type": sort_type.type,
      "category_id": category_id.type,
      "query_type": query_type.type,
      "last_tid": last_tid,
      "pub_time": pub_time,
      "reply_time": reply_time,
      "hot_value": hot_value,
    });
    if (response.data != null) {
      var list = response.data['data']['list'] as List;
      topicList = list.map((i) => Topic.fromJson(i)).toList();
    } else {
      topicList = [];
    }

    notifyListeners();

  }
}
