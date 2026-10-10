import 'package:grfanonymous/models/bannerItem.dart';
import 'package:grfanonymous/models/topicList.dart';
import 'package:grfanonymous/pageRequest/requestUtils.dart';
import 'package:dio/dio.dart';

class HomePageRequest {
  List<BannerItem> bannerList = [];
  List<Topic> topicList = [];
  // Dio dio = Dio();
  int hotValue = 0;
  int lastTid = 0;
  bool nextPage = true;
  int pubTime = 0;
  int replyTime = 0;
  int total = 0;
  SortType sortType = SortType.reply;
  CategoryId categoryId = CategoryId.recommend;
  QueryType queryType = QueryType.homepage;
  bool _isLoading = false;

  Future getBanner() async {
    Response response =
        await DioInstance.instance().get(path: "/community/banner");
    if (response.data != null && response.data['Code'] == 0) {
      var list = response.data['data']['banner_list'] as List;
      bannerList = list.map((i) => BannerItem.fromJson(i)).toList();
    } else {
      bannerList = [];
    }
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
    if (_isLoading || (onLoad && !nextPage)) return;
    _isLoading = true;
    try {
      Response response = await DioInstance.instance()
          .get(path: "/community/topic/list", param: {
        "sort_type": onLoad ? sortType.type : sort_type.type,
        "category_id": onLoad ? categoryId.type : category_id.type,
        "query_type": onLoad ? queryType.type : query_type.type,
        "last_tid": onLoad ? lastTid : last_tid,
        "pub_time": onLoad ? pubTime : pub_time,
        "reply_time": onLoad ? replyTime : reply_time,
        "hot_value": onLoad ? hotValue : hot_value,
      });
      if (response.data == null || response.data['Code'] != 0) {
        throw StateError('帖子列表请求失败: ${response.data?['Message']}');
      }
      var list = response.data['data']['list'] as List;
      final topics = list.map((i) => Topic.fromJson(i)).toList();

      hotValue = response.data['data']['hot_value'] ?? 0;
      lastTid = response.data['data']['last_tid'] ?? 0;
      nextPage = response.data['data']['next_page'] ?? false;
      pubTime = response.data['data']['pub_time'] ?? 0;
      replyTime = response.data['data']['reply_time'] ?? 0;
      total = response.data['data']['total'] ?? 0;
      if (!onLoad) {
        sortType = sort_type;
        categoryId = category_id;
        queryType = query_type;
        topicList = topics;
      } else {
        topicList.addAll(topics);
      }
    } finally {
      _isLoading = false;
    }
  }
}
