import 'package:demo/models/webViewContent.dart';
import 'package:demo/pageRequest/requestUtils.dart';
import 'package:dio/dio.dart';
import 'package:oktoast/oktoast.dart';

class WebViewRequest {
  late WebViewContent webViewContent;

  Future getWebViewContent(String topicId) async {
    Response response = await DioInstance.instance()
        .get(path: "/community/topic/$topicId", param: {
      "id": topicId,
    });
    if (response.data != null) {
      // showToast(response.data['data']['comment_num'].toString());
      webViewContent = WebViewContent.fromJson(response.data['data']);

    } else {
      showToast("帖子信息获取失败");
    }
  }
}
