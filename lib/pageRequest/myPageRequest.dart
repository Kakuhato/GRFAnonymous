import 'package:grfanonymous/models/userData.dart';
import 'package:grfanonymous/pageRequest/requestUtils.dart';
import 'package:dio/dio.dart';
import 'package:oktoast/oktoast.dart';

class MyPageRequest {
  late UserData userData = defaultUserData;
  late GameData gameData = defaultGameData;

  Future getUserData() async {
    Response response = await DioInstance.instance().post(
      path: "/community/member/info",
      data: {},
    );
    if (response.data != null && response.data['Code'] == 0) {
      userData = UserData.fromJson(response.data['data']['user']);
    } else {
      showToast("用户信息获取失败");
    }
  }

  Future getGameData() async {
    Response response = await DioInstance.instance().post(
      path: "/community/game/info",
      data: {},
    );
    if (response.data != null && response.data['Code'] == 0) {
      gameData = GameData.fromJson(response.data['data']);
    } else {
      showToast("游戏信息获取失败");
    }
  }

  Future getOtherUserData(String uid) async {
    Response response = await DioInstance.instance().post(
      path: "/community/member/info",
      data: {
        "uid": int.parse(uid),
      },
    );
    if (response.data != null && response.data['Code'] == 0) {
      userData = UserData.fromJson(response.data['data']['user']);
    } else {
      showToast("用户信息获取失败");
    }
  }

  Future getOtherGameData(String uid) async {
    Response response = await DioInstance.instance().post(
      path: "/community/game/info",
      data: {
        "uid": int.parse(uid),
      },
    );
    if (response.data != null && response.data['Code'] == 0) {
      gameData = GameData.fromJson(response.data['data']);
    } else {
      showToast("用户信息获取失败");
    }
  }

}
