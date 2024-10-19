import 'package:dio/dio.dart';
import 'package:grfanonymous/models/notifications/likeList.dart';
import 'package:oktoast/oktoast.dart';

import '../requestUtils.dart';

class LikeNotificationRequest {
  List<LikeItem> likeList = [];
  int total = 0;
  int unread = 0;
  int page = 1;

  Future getLikeNotification(bool onFresh) async {
    Response response = await DioInstance.instance().get(
      path: "/community/message/list",
      param: {
        "type": 2,
        "page_num": onFresh ? 1 : page + 1,
        "pageSize": 20,
      },
    );

    if (response.data['Code'] == 0) {
      if(onFresh){
        likeList = response.data['data']['list']
            .map<LikeItem>((item) => LikeItem.fromJson(item))
            .toList();
        page = 1;
      }
      else{
        likeList.addAll(response.data['data']['list']
            .map<LikeItem>((item) => LikeItem.fromJson(item))
            .toList());
        page++;
      }
      unread = response.data['data']['unread_num'];
      total = response.data['data']['total'];
    }
    else{
      showToast("获取点赞通知失败");
    }
  }


}
