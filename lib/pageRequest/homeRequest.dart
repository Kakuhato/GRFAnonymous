import 'package:grfanonymous/models/bannerItem.dart';
import 'package:grfanonymous/models/topicList.dart';
import 'package:grfanonymous/pageRequest/requestUtils.dart';
import 'package:dio/dio.dart';
import 'package:grfanonymous/models/top_topic.dart';
import 'package:oktoast/oktoast.dart';

class HomePageRequest {
  List<BannerItem> bannerList = [];
  List<Topic> topicList = [];
  List<TopTopic> topTopics = [];
  // Dio dio = Dio();
  int hotValue = 0;
  int lastTid = 0;
  bool nextPage = true;
  int pubTime = 0;
  int replyTime = 0;
  int updateTime = 0;
  int total = 0;
  int categorySubId = 1;
  int pageNum = 1;
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

  Future<List<TopTopic>> _getTopTopics(CategoryId category) async {
    try {
      final response = await DioInstance.instance().get(
        path: '/community/top', param: {'category_id': category.type},
      );
      if (response.data == null || response.data['Code'] != 0) {
        throw StateError('公告请求失败');
      }
      return (response.data['data'] as List? ?? [])
          .map((item) => TopTopic.fromJson(item))
          .where((item) => item.topicId > 0 && item.title.isNotEmpty)
          .toList();
    } catch (_) {
      // 公告失败不阻塞帖子；清空以免显示上一分类的公告。
      showToast('公告加载失败，下拉刷新可重试');
      return [];
    }
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
    int category_sub_id = 1,
  }) async {
    if (_isLoading || (onLoad && !nextPage)) return;
    _isLoading = true;
    try {
      final requestedCategory = onLoad ? categoryId : category_id;
      final official = requestedCategory == CategoryId.official;
      final requestedPage = onLoad ? pageNum + 1 : 1;
      final requestedQuery = official ? QueryType.official
          : (onLoad ? queryType : query_type);
      Response response = await DioInstance.instance()
          .get(path: "/community/topic/list", param: {
        "sort_type": official ? 1 : (onLoad ? sortType.type : sort_type.type),
        "category_id": onLoad ? categoryId.type : category_id.type,
        "query_type": requestedQuery.type,
        if (official) "category_sub_id": onLoad ? categorySubId : category_sub_id,
        if (official) "page_num": requestedPage,
        "last_tid": onLoad ? lastTid : last_tid,
        "pub_time": onLoad ? pubTime : pub_time,
        "reply_time": onLoad ? replyTime : reply_time,
        "hot_value": onLoad ? hotValue : hot_value,
        "theme_id": 0,
        "update_time": onLoad ? updateTime : 0,
        "is_new_mark": 0,
      });
      if (response.data == null || response.data['Code'] != 0) {
        throw StateError('帖子列表请求失败: ${response.data?['Message']}');
      }
      var list = response.data['data']['list'] as List;
      final topics = list.map((i) => Topic.fromJson(i)).toList();
      final announcements = onLoad ? topTopics : await _getTopTopics(requestedCategory);

      pageNum = requestedPage;
      hotValue = response.data['data']['hot_value'] ?? 0;
      lastTid = response.data['data']['last_tid'] ?? 0;
      nextPage = response.data['data']['next_page'] ?? false;
      pubTime = response.data['data']['pub_time'] ?? 0;
      replyTime = response.data['data']['reply_time'] ?? 0;
      updateTime = response.data['data']['update_time'] ?? 0;
      total = response.data['data']['total'] ?? 0;
      if (!onLoad) {
        topTopics = announcements;
        sortType = sort_type;
        categoryId = category_id;
        queryType = requestedQuery;
        categorySubId = category_sub_id;
        topicList = topics;
      } else {
        topicList.addAll(topics);
      }
    } finally {
      _isLoading = false;
    }
  }
}
