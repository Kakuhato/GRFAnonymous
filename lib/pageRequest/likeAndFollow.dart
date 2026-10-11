import 'package:grfanonymous/pageRequest/requestUtils.dart';
import 'package:dio/dio.dart';
import 'package:oktoast/oktoast.dart';

class LikeAndFollow {
  bool isSignIn = false;
  int _signInRevision = 0;

  Future<bool> like(String id) async {
    Response response = await DioInstance.instance().get(
      path: "/community/topic/like/$id",
      param: {"id": id},
    );

    if (response.data["Code"] == 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> getSignInStatus() async {
    final revision = _signInRevision;
    final response = await DioInstance.instance().get(
      path: '/community/task/get_current_sign_in_status',
    );
    // 签到成功前发出的状态请求不能用旧响应覆盖新状态。
    if (revision != _signInRevision) return;
    final body = response.data;
    if (body is! Map) {
      showToast('签到信息请求错误');
      return;
    }
    if (body['Code'] == 30010) {
      isSignIn = true;
      return;
    }
    final data = body['data'];
    if (body['Code'] == 0 && data is Map) {
      final value = data['has_sign_in'];
      if (value == true || value == 1 || value == '1') {
        isSignIn = true;
        return;
      }
      if (value == false || value == 0 || value == '0') {
        isSignIn = false;
        return;
      }
    }
    showToast(body['Message']?.toString() ?? '签到信息请求错误');
  }

  Future<bool> doSignIn() async {
    final response = await DioInstance.instance().post(
      path: '/community/task/sign_in',
    );
    final body = response.data;
    if (body is! Map) {
      showToast('签到失败，请重试');
      return false;
    }
    if (body['Code'] == 0 || body['Code'] == 30010) {
      _signInRevision++;
      isSignIn = true;
      showToast(body['Code'] == 0 ? '签到成功' : '今日已签到');
      return true;
    }
    final message = body['Message']?.toString();
    showToast(message == null || message.isEmpty ? '签到失败，请重试' : message);
    return false;
  }

  Future<bool> follow(int userID) async {
    Response response = await DioInstance.instance()
        .get(path: "/community/member/follow/$userID");
    if (response.data["Code"] == 0) {
      showToast(response.data["Message"]);
      return true;
    } else {
      showToast("操作失败");
      return false;
    }
  }

  Future<bool> share(String id) async {
    Response response = await DioInstance.instance().get(
      path: "/community/topic/share/$id",
      param: {"id": id},
    );
    if (response.data != null && response.data["Code"] == 0) {
      return true;
    } else {
      showToast(response.data["Message"]);
      return false;
    }
  }
}
