import '../models/topicList.dart';
import 'requestUtils.dart';

class ThemeDetail {
  final String name;
  final String description;
  final String image;
  final int views;
  final int discussions;

  ThemeDetail.fromJson(Map data)
      : name = data['name']?.toString() ?? '',
        description = data['desc']?.toString() ?? '',
        image = data['show_pic']?.toString() ?? '',
        views = int.tryParse('${data['view_num']}') ?? 0,
        discussions = int.tryParse('${data['discuss_num']}') ?? 0;
}

class ThemeTopicPage {
  final List<Topic> topics;
  final bool hasMore;
  final Map<String, int> cursor;

  ThemeTopicPage.fromJson(Map data)
      : topics = (data['list'] as List)
            .map((item) => Topic.fromJson(Map<String, dynamic>.from(item as Map))).toList(),
        hasMore = (data['list'] as List).isNotEmpty &&
            (data['next_page'] == true || data['next_page'] == 1),
        cursor = {
          for (final key in ['pub_time', 'reply_time', 'update_time', 'hot_value', 'last_tid', 'is_new_mark'])
            key: int.tryParse('${data[key]}') ?? 0,
        };
}

class ThemeRequest {
  Map _data(dynamic body) {
    if (body is! Map || '${body['Code']}' != '0' || body['data'] is! Map) {
      throw const FormatException('话题数据获取失败');
    }
    return body['data'] as Map;
  }

  Future<ThemeDetail> detail(int themeId) async {
    final response = await DioInstance.instance().post(
      path: '/community/theme_detail', data: {'theme_id': themeId},
    );
    final info = _data(response.data)['theme_info'];
    if (info is! Map) throw const FormatException('话题详情格式异常');
    return ThemeDetail.fromJson(info);
  }

  Future<ThemeTopicPage> topics(int themeId, {
    required int sort, required int page, Map<String, int> cursor = const {},
  }) async {
    final response = await DioInstance.instance().get(
      path: '/community/topic/list',
      param: {
        'sort_type': sort, 'category_id': 100, 'page_num': page,
        'page_size': 10, 'query_type': 5, 'theme_id': themeId,
        for (final key in ['pub_time', 'reply_time', 'update_time', 'hot_value', 'last_tid', 'is_new_mark'])
          key: cursor[key] ?? 0,
      },
    );
    final data = _data(response.data);
    if (data['list'] is! List) throw const FormatException('话题帖子格式异常');
    return ThemeTopicPage.fromJson(data);
  }
}
