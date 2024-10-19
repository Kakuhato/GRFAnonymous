import 'package:grfanonymous/pageRequest/requestUtils.dart';
import 'package:dio/dio.dart';
import 'package:oktoast/oktoast.dart';

class LikeAndFollow {
  bool isSignIn = false;

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
    Response response = await DioInstance.instance().get(
      path: "/community/task/get_current_sign_in_status",
    );
    if (response.data["Code"] == 0) {
      isSignIn = response.data["data"]["has_sign_in"];
    } else if (response.data["Code"] == 30010) {
      showToast(response.data["Message"]);
      isSignIn = response.data["data"]["has_sign_in"];
    } else {
      showToast("签到信息请求错误");
    }
  }

  Future<bool> doSignIn() async {
    Response response = await DioInstance.instance().post(
      path: "/community/task/sign_in",
    );
    if (response.data["Code"] == 0) {
      showToast("签到成功");
      return true;
    } else if (response.data["Code"] == 30010) {
      showToast(response.data["Message"]);
      return true;
    } else {
      showToast(response.data["签到失败"]);
      return false;
    }
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
}
