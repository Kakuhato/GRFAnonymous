import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html;
import '../models/topicList.dart';
import '../models/search_user.dart';
import 'requestUtils.dart';

enum SearchType {
  topics(1, '帖子'),
  users(2, '用户');

  const SearchType(this.value, this.label);
  final int value;
  final String label;
}

class SearchResult {
  const SearchResult({required this.topics, required this.users, required this.total, required this.hasMore});

  final List<Topic> topics;
  final List<SearchUser> users;
  final int? total;
  final bool hasMore;
}

class TopicSearchException implements Exception {
  const TopicSearchException(this.message);
  final String message;
}

class SearchRequest {
  Future<bool> topicExists(String topicId, {CancelToken? cancelToken}) async {
    late Response response;
    try {
      response = await DioInstance.instance().get(
        path: '/community/topic/$topicId',
        param: {'id': topicId},
        cancelToken: cancelToken,
      );
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) rethrow;
      if (error.response?.statusCode == 404) return false;
      if (error.response?.statusCode == 401 || error.response?.statusCode == 403) {
        throw const TopicSearchException('无法查看帖子，请登录后重试');
      }
      throw const TopicSearchException('暂时无法确认帖子是否存在，请重试');
    }
    final body = response.data;
    if (body is! Map) throw const TopicSearchException('帖子响应异常，请重试');
    if ('${body['Code']}' == '20005') return false;
    if ('${body['Code']}' != '0') {
      throw TopicSearchException(body['Message']?.toString() ?? '无法查看帖子，请重试');
    }
    final data = body['data'];
    if (data is! Map || '${data['topic_id']}' != topicId) {
      throw const TopicSearchException('帖子数据异常，请重试');
    }
    return true;
  }

  Future<SearchResult> search({
    required String content,
    required int page,
    SearchType searchType = SearchType.topics,
    CancelToken? cancelToken,
  }) async {
    const pageSize = 10;
    late Response response;
    try {
      // 现有拦截器自动携带当前登录态的 Authorization。
      response = await DioInstance.instance().post(
        path: '/community/search/info',
        data: {
          'search_type': searchType.value,
          'page_num': page,
          'page_size': pageSize,
          'content': content,
          'sort_type': 1,
          'category_id': 0,
        },
        cancelToken: cancelToken,
      );
    } on DioException catch (error) {
      if (error.response?.statusCode == 401 || error.response?.statusCode == 403) {
        throw const TopicSearchException('请先登录；如果已经登录，请重新登录后搜索');
      }
      rethrow;
    }
    final body = response.data;
    if (body is! Map) throw const TopicSearchException('搜索响应异常，请重试');
    if ('${body['Code']}' != '0') {
      throw TopicSearchException(body['Message']?.toString() ?? '搜索失败，请重试');
    }
    final data = body['data'];
    if (data is! Map || data['list'] is! List) {
      throw const TopicSearchException('搜索结果格式异常，请重试');
    }
    final list = data['list'] as List;
    final users = <SearchUser>[];
    final topics = <Topic>[];
    for (final item in list) {
      final json = Map<String, dynamic>.from(item as Map);
      if (searchType == SearchType.users) {
        users.add(SearchUser.fromJson(json));
        continue;
      }
      // 搜索结果可能包含高亮标签，帖子卡片使用纯文本摘要。
      for (final field in ['title', 'content']) {
        final fragment = html.parseFragment('${json[field] ?? ''}');
        for (final element in fragment.querySelectorAll('script, style')) {
          element.remove();
        }
        json[field] = fragment.text ?? '';
      }
      topics.add(Topic.fromJson(json));
    }
    final total = int.tryParse('${data['total']}');
    return SearchResult(
      topics: topics,
      users: users,
      total: total,
      hasMore: list.isNotEmpty && (total != null
          ? page * pageSize < total
          : list.length == pageSize),
    );
  }
}
