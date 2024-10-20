import 'package:dio/dio.dart';
import 'package:grfanonymous/models/notifications/replyList.dart';
import 'package:oktoast/oktoast.dart';

import '../requestUtils.dart';

class ReplyNotificationRequest {
  List<ReplyItem> replyList = [];
  int total = 0;
  int unread = 0;
  int page = 1;

  Future getReplyNotification(bool onFresh) async {
    Response response = await DioInstance.instance().get(
      path: "/community/message/list",
      param: {
        "type": 1,
        "page_num": onFresh ? 1 : page + 1,
        "pageSize": 20,
      },
    );

    if (response.data['Code'] == 0) {
      if(onFresh){
        replyList = response.data['data']['list']
            .map<ReplyItem>((item) => ReplyItem.fromJson(item))
            .toList();
        page = 1;
      }
      else{
        replyList.addAll(response.data['data']['list']
            .map<ReplyItem>((item) => ReplyItem.fromJson(item))
            .toList());
        page++;
      }
      unread = response.data['data']['unread_num'];
      total = response.data['data']['total'];
    }
    else{
      showToast("获取回复通知失败");
    }
  }

  Future readAll() async{
    Response response = await DioInstance.instance().post(
      path: "/community/message/read_all",
      data: {},
    );
  }


}
