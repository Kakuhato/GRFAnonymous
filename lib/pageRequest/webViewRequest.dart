import 'package:grfanonymous/models/replyList.dart';
import 'package:grfanonymous/models/webViewContent.dart';
import 'package:grfanonymous/pageRequest/requestUtils.dart';
import 'package:dio/dio.dart';
import 'package:oktoast/oktoast.dart';

class WebViewRequest {
  late WebViewContent webViewContent;
  List<ListElement> replyList = [];
  int _lastId = 0;
  bool _isLoading = false;
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
  }) async {
    if (_isLoading) return;
    _isLoading = true;
    Response response = await DioInstance.instance().post(
      path: "/community/comment/list",
      data: {
        "topic_id": int.tryParse(topicId),
        "sort": 0,
        "last_id": isInit ? lastId : _lastId,
        "only_author": false,
      },
    );
    if (response.data != null) {
      _lastId = response.data['data']['last_id'];
      hasNext = response.data['data']['next_page'];
      var list = response.data['data']['list'] as List;

      if (!isInit) {
        replyList.addAll(list.map((i) => ListElement.fromJson(i)).toList());
      } else {
        replyList = list.map((i) => ListElement.fromJson(i)).toList();
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

  //回传detail

}
