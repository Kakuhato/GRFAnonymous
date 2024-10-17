import 'package:grfanonymous/models/bannerItem.dart';
import 'package:grfanonymous/models/topicList.dart';
import 'package:grfanonymous/pageRequest/requestUtils.dart';
import 'package:dio/dio.dart';

class FollowPageRequest {
  List<Topic> topicList = [];
  // Dio dio = Dio();
  int hotValue = 0;
  int lastTid = 0;
  bool nextPage = true;
  int pubTime = 0;
  int replyTime = 0;
  int total = 0;
  SortType sortType = SortType.reply;
  CategoryId categoryId = CategoryId.none;
  QueryType queryType = QueryType.follow;
  bool _isLoading = false;

  Future getTopic({
    SortType sort_type = SortType.reply,
    CategoryId category_id = CategoryId.none,
    QueryType query_type = QueryType.follow,
    int last_tid = 0,
    int pub_time = 0,
    int reply_time = 0,
    int hot_value = 0,
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
      });
    } else {
      response = await DioInstance.instance()
          .get(path: "/community/topic/list", param: {
        "sort_type":sortType.type,
        "category_id": categoryId.type,
        "query_type": queryType.type,
        "last_tid": lastTid,
        "pub_time": pubTime,
      });
    }
    if (response.data != null) {
      // print(response.requestOptions.queryParameters);
      // print(response);
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
    }
    _isLoading = false;
  }
}
