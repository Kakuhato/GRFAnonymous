import 'package:grfanonymous/models/replyList.dart';
import 'package:grfanonymous/models/webViewContent.dart';
import 'package:grfanonymous/pageRequest/requestUtils.dart';
import 'package:dio/dio.dart';
import 'package:oktoast/oktoast.dart';

class WebViewRequest {
  late WebViewContent webViewContent;
  List<SingleComment> replyList = [];
  int _lastId = 0;
  bool _isLoading = false;
  int _sort = 0;
  late bool hasNext;

  Future getWebViewContent(String topicId) async {
    Response response = await DioInstance.instance()
        .get(path: "/community/topic/$topicId", param: {
      "id": topicId,
    });
    if (response.data["Code"] == 0) {
      // showToast(response.data['data']['comment_num'].toString());
      webViewContent = WebViewContent.fromJson(response.data['data']);
    } else {
      showToast("帖子信息获取失败");
    }
  }

  Future getReplyList(
    String topicId, {
    int lastId = 0,
    bool isInit = true,
    int sort = 0,
    bool isAuther = false,
  }) async {
    if (_isLoading) return;
    _isLoading = true;
    Response response = await DioInstance.instance().post(
      path: "/community/comment/list",
      data: {
        "topic_id": int.tryParse(topicId),
        "sort": (isInit) ? sort : _sort,
        "last_id": isInit ? lastId : _lastId,
        "only_author": isAuther,
      },
    );
    if (response.data != null) {
      _lastId = response.data['data']['last_id'];
      hasNext = response.data['data']['next_page'];
      var list = response.data['data']['list'] as List;
      _sort = sort;

      if (!isInit) {
        replyList.addAll(list.map((i) => SingleComment.fromJson(i)).toList());
      } else {
        replyList = list.map((i) => SingleComment.fromJson(i)).toList();
      }
    } else {
      replyList = [];
      showToast("评论信息获取失败");
    }
    _isLoading = false;
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
