import 'package:grfanonymous/models/userData.dart';
import 'package:grfanonymous/pageRequest/requestUtils.dart';
import 'package:dio/dio.dart';
import 'package:oktoast/oktoast.dart';

class MyPageRequest {
  late UserData userData = UserData(
    authLock: 0,
    authType: 0,
    avatar: "",
    exp: 0,
    fans: 0,
    favors: 0,
    follows: 0,
    gameCommanderLevel: 0,
    gameNickName: "",
    gameUid: 0,
    ipLocation: "",
    isAdmin: false,
    isAuthor: false,
    isFollow: false,
    level: 0,
    likes: 0,
    nextLvExp: 0,
    nickName: "",
    score: 0,
    showFans: false,
    showFavor: false,
    showFollow: false,
    showGame: false,
    signature: "",
    uid: 0,
  );
  late GameData gameData;

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
}
