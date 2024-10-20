
import 'package:dio/dio.dart';
import 'package:grfanonymous/models/notifications/InfoList.dart';
import 'package:oktoast/oktoast.dart';

import '../requestUtils.dart';

class InfoNotificationRequest {
  List<InfoItem> infoList = [];
  int total = 0;
  int unread = 0;
  int page = 1;

  Future getInfoNotification(bool onFresh) async {
    Response response = await DioInstance.instance().get(
      path: "/community/message/list",
      param: {
        "type": 4,
        "page_num": onFresh ? 1 : page + 1,
        "pageSize": 20,
      },
    );

    if (response.data['Code'] == 0) {
      if(onFresh){
        infoList = response.data['data']['list']
            .map<InfoItem>((item) => InfoItem.fromJson(item))
            .toList();
        page = 1;
      }
      else{
        infoList.addAll(response.data['data']['list']
            .map<InfoItem>((item) => InfoItem.fromJson(item))
            .toList());
        page++;
      }
      unread = response.data['data']['unread_num'];
      total = response.data['data']['total'];
    }
    else{
      showToast("获取官方通知失败");
    }
  }


}
