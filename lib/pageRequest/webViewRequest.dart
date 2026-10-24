import 'package:grfanonymous/models/replyList.dart';
import 'package:grfanonymous/models/webViewContent.dart';
import 'package:grfanonymous/pageRequest/requestUtils.dart';
import 'package:dio/dio.dart';
import 'package:oktoast/oktoast.dart';

class TopicRequestException implements Exception {
  const TopicRequestException(this.message);
  final String message;
}

class WebViewRequest {
  late WebViewContent webViewContent;
  List<SingleComment> replyList = [];
  int _lastId = 0;
  bool _isLoading = false;
  int _sort = 0;
  bool hasNext = false;

  Future<void> getWebViewContent(String topicId) async {
    try {
      final response = await DioInstance.instance().get(
        path: '/community/topic/$topicId', param: {'id': topicId},
      );
      final body = response.data;
      if (body is! Map) throw const TopicRequestException('帖子响应异常，请重试');
      if ('${body['Code']}' == '20005') {
        throw const TopicRequestException('帖子不存在或已删除');
      }
      if ('${body['Code']}' != '0') {
        throw TopicRequestException(body['Message']?.toString() ?? '帖子加载失败，请重试');
      }
      final data = body['data'];
      if (data is! Map || '${data['topic_id']}' != topicId) {
        throw const TopicRequestException('帖子数据异常，请重试');
      }
      webViewContent = WebViewContent.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw const TopicRequestException('帖子不存在或已删除');
      }
      if (error.response?.statusCode == 401 || error.response?.statusCode == 403) {
        throw const TopicRequestException('无法查看帖子，请登录后重试');
      }
      throw const TopicRequestException('帖子加载失败，请检查网络后重试');
    }
  }

  Future<void> getReplyList(
    String topicId, {
    int lastId = 0,
    bool isInit = true,
    int sort = 0,
    bool isAuther = false,
  }) async {
    if (_isLoading) return;
    _isLoading = true;
    try {
      final response = await DioInstance.instance().post(
        path: '/community/comment/list',
        data: {
          'topic_id': int.tryParse(topicId),
          'sort': isInit ? sort : _sort,
          'last_id': isInit ? lastId : _lastId,
          'only_author': isAuther,
        },
      );
      final body = response.data;
      if (body is! Map) throw const TopicRequestException('评论响应异常，请重试');
      if ('${body['Code']}' != '0') {
        throw TopicRequestException(body['Message']?.toString() ?? '评论加载失败，请重试');
      }
      final data = body['data'];
      if (data is! Map || data['list'] is! List) {
        throw const TopicRequestException('评论数据异常，请重试');
      }
      final comments = (data['list'] as List)
          .map((item) => SingleComment.fromJson(Map<String, dynamic>.from(item as Map))).toList();
      if (isInit) {
        replyList = comments;
        _sort = sort;
      } else {
        replyList.addAll(comments);
      }
      _lastId = int.tryParse('${data['last_id']}') ?? 0;
      hasNext = data['next_page'] == true || data['next_page'] == 1;
    } finally {
      // 网络异常、业务错误和解析失败都必须释放加载锁，才能重试。
      _isLoading = false;
    }
  }

  Future<bool> likeComment(String topicId, int commentId) async {
    Response response = await DioInstance.instance()
        .post(path: "/community/comment/like", data: {
      "comment_id": commentId,
      "topic_id": int.tryParse(topicId),
    });

    if (response.data["Code"] == 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> favorTopic(String topicId) async {
    Response response = await DioInstance.instance().get(
      path: "/community/topic/favor/$topicId",
      param: {
        "id": topicId,
      },
    );
    if (response.data["Code"] == 0) {
      return true;
    } else {
      return false;
    }
  }

  //评论
  Future<bool> submitComment(String topicId, String content,{
    int commentId = 0,
    int commentSubId = 0,
  }) async {
    Response response = await DioInstance.instance().post(
      path: "/community/comment/reply",
      data: {
        "code" :"",
        "comment_id": commentId,
        "comment_sub_id": commentSubId,
        "content": content,
        "topic_id": int.tryParse(topicId),
      },
    );
    if (response.data["Code"] == 0) {
      showToast(response.data["Message"]);
      return true;
    } else {
      showToast(response.data["Message"]);
      return false;
    }
  }

  Future<SingleComment> getCommentDetail(String topicId, int commentId) async {
    Response response = await DioInstance.instance().post(
      path: "/community/comment/detail",
      data: {
        "comment_id": commentId,
        "topic_id": int.tryParse(topicId),
      },
    );
    if(response.data["Code"] == 0){
      showToast("发表成功");
      return SingleComment.fromJson(response.data["data"]);
    }
    else{
      showToast(response.data["Message"]);
      return SingleComment.fromJson({});
    }
  }

  //回传detail
}
