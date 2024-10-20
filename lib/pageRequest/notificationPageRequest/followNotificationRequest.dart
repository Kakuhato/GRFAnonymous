import 'package:dio/dio.dart';
import 'package:grfanonymous/models/notifications/followList.dart';
import 'package:oktoast/oktoast.dart';

import '../requestUtils.dart';

class FollowNotificationRequest {
  List<FollowItem> followList = [];
  int total = 0;
  int unread = 0;
  int page = 1;

  Future getFollowNotification(bool onFresh) async {
    Response response = await DioInstance.instance().get(
      path: "/community/message/list",
      param: {
        "type": 3,
        "page_num": onFresh ? 1 : page + 1,
        "pageSize": 20,
      },
    );

    if (response.data['Code'] == 0) {
      if(onFresh){
        followList = response.data['data']['list']
            .map<FollowItem>((item) => FollowItem.fromJson(item))
            .toList();
        page = 1;
      }
      else{
        followList.addAll(response.data['data']['list']
            .map<FollowItem>((item) => FollowItem.fromJson(item))
            .toList());
        page++;
      }
      unread = response.data['data']['unread_num'];
      total = response.data['data']['total'];
    }
    else{
      showToast("获取关注通知失败");
    }
  }


}
