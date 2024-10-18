import 'package:dio/dio.dart';
import 'package:grfanonymous/pageRequest/requestUtils.dart';
import 'package:oktoast/oktoast.dart';

import '../models/shopItem.dart';

class ShopPageRequest {
  List<ShopItem> shopItemList = [];

  Future getShopItemList() async {
    Response response = await DioInstance.instance().get(
      path: "/community/item/exchange_list",
    );
    if (response.data["Code"] == 0) {
      var list = response.data['data']['list'] as List;
      shopItemList = list.map((i) => ShopItem.fromJson(i)).toList();
    } else {
      shopItemList = [];
      showToast("商店获取失败");
    }
  }

  Future<void> exchangeItem(int exchangeId) async {
    Response response = await DioInstance.instance().post(
      path: "/community/item/exchange",
      data: {
        "exchange_id": exchangeId,
      },
    );
    if (response.data["Code"] == 0) {
      if(response.data["Message"] == "OK"){
        showToast("兑换成功");
        return;
      }
      else{
        showToast(response.data["Message"]);
      }
    } else {
      showToast("兑换失败");
    }
  }
}
