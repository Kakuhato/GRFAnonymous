import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import '../models/shopItem.dart';
import '../pageRequest/myPageRequest.dart';
import '../pageRequest/shopRequest.dart';
import '../ui/uiSizeUtil.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<StatefulWidget> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  ShopPageRequest shopPageRequest = ShopPageRequest();
  MyPageRequest myPageRequest = MyPageRequest();

  @override
  void initState() {
    _refresh();
    super.initState();
  }

  Future<void> _refresh() async {
    await myPageRequest.getUserData();
    await shopPageRequest.getShopItemList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(245, 245, 245, 1),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(UiSizeUtil.headerHeight),
        child: AppBar(
          title: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(right: 60),
              child: Text(
                "兑  换",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: UiSizeUtil.headerFontSize,
                ),
              )),
          backgroundColor: Colors.black,
          automaticallyImplyLeading: true,
          iconTheme: IconThemeData(
            color: Colors.white,
            size: UiSizeUtil.topIconSize,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.symmetric(horizontal: 10).add(
              const EdgeInsets.only(top: 10),
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/coin.png", width: 25, height: 25),
                Text(
                  " ${myPageRequest.userData.score}",
                  style: TextStyle(
                    fontSize: UiSizeUtil.shopScoreFontSize,
                    color: const Color.fromRGBO(242, 121, 49, 1),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 0),
          Expanded(
            child: WaterfallFlow.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate:
                  const SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 每行显示两个商品
                crossAxisSpacing: 10, // 列之间的间距
                mainAxisSpacing: 10, // 行之间的间距
              ),
              itemCount: shopPageRequest.shopItemList.length, // 商品数量
              itemBuilder: (context, index) {
                return _buildShopItem(shopPageRequest.shopItemList[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopItem(ShopItem shopItem) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3), // 改变阴影位置
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          _showExchangeDialog(context, shopItem);
          // showToast("msg");
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 第一行：限购次数
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              color: Colors.orange,
              child: Text(
                shopItem.cycle == "day"
                    ? "每日限购 ${shopItem.maxExchangeCount - shopItem.exchangeCount}/${shopItem.maxExchangeCount}"
                    : "每月限购 ${shopItem.maxExchangeCount - shopItem.exchangeCount}/${shopItem.maxExchangeCount}",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: UiSizeUtil.shopLimitFontSize,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // 第二行：商品图片
            Center(
              child: CachedNetworkImage(
                imageUrl: shopItem.itemPic, // 替换为商品图片的URL
                height: 100,
              ),
            ),
            const SizedBox(height: 10),

            // 第三行：商品信息
            Center(
              // padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                "${shopItem.itemName}*${shopItem.itemCount}",
                style: TextStyle(
                  fontSize: UiSizeUtil.shopItemNameFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 5),

            // 第四行：所需积分
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                color: Color.fromRGBO(63, 71, 76, 1),
              ),
              width: double.infinity,
              child: Center(
                child: Text(
                  shopItem.useScore.toString(),
                  style: TextStyle(
                    fontSize: UiSizeUtil.shopScoreFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExchangeDialog(BuildContext context, ShopItem shopItem) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("确认交换"),
          content: Container(
            constraints: const BoxConstraints(maxHeight: 180),
            child: Column(
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: "使用 ",
                        style: TextStyle(fontSize: 16),
                      ),
                      TextSpan(
                        text: "${shopItem.useScore}",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color.fromRGBO(242, 121, 49, 1), // 这里设置积分的颜色
                          fontWeight: FontWeight.bold, // 如果需要加粗，也可以加上
                        ),
                      ),
                      const TextSpan(
                        text: " 积分兑换",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                CachedNetworkImage(
                  imageUrl: shopItem.itemPic,
                  height: 130,
                ),
                Text(
                  "${shopItem.itemName}*${shopItem.itemCount}",
                  style: TextStyle(
                    fontSize: UiSizeUtil.shopItemNameFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // 按钮居中对齐
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // 关闭对话框
                  },
                  child: const Text("取消"),
                ),
                const SizedBox(width: 20), // 添加一点水平间距
                TextButton(
                  onPressed: () async {
                    await shopPageRequest.exchangeItem(shopItem.exchangeId);
                    _refresh();
                    Navigator.of(context).pop(); // 关闭对话框
                  },
                  child: const Text("确认"),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
