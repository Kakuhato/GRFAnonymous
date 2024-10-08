import 'dart:math';

import 'package:demo/models/BannerItem.dart';
import 'package:demo/models/TopicList.dart';
import 'package:demo/pageRequest/homeRequest.dart';
import 'package:demo/pageRequest/requestUtil.dart';
import 'package:demo/pages/web_view_page.dart';
import 'package:demo/utils/routeUtil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

// extension fff on int{
//   double get d => toDouble();
//
//   double toD(){
//     return toDouble();
//   }
// }

class _HomePageState extends State<HomePage> {
  HomePageRequest homePageRequest = HomePageRequest();

  @override
  void initState() {
    super.initState();
    homePageRequest.initDio();
    homePageRequest.getBanner();
    homePageRequest.getTopic(SortType.reply, CategoryId.recommend, QueryType.homepage);
  }


  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomePageRequest>(
        create: (context) {
          return homePageRequest;
        },
        child: Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.search,
                    color: Colors.white,
                    size: 40,
                  ))
            ],
            title: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.only(left: 55),
                child: const Text(
                  "主  页",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                )),
            backgroundColor: Colors.black,
          ),
          backgroundColor: const Color.fromRGBO(245, 245, 245, 1),
          body: SafeArea(
              child: ListView(
            children: [
              _bannerBuilder(),
              Container(
                height: 110,
                width: double.infinity,
                padding: const EdgeInsets.only(
                    top: 10, bottom: 10, left: 25, right: 25),
                margin: const EdgeInsets.only(
                    top: 5, bottom: 5, left: 10, right: 10),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  // border: Border.all(color: Colors.grey)
                ),
                child: _toolBar(), //导航栏
              ),
              _topicListBuilder(),
            ],
          )),
        ));
  }

  Widget _bannerBuilder() {
    return Consumer<HomePageRequest>(builder: (context, value, child) {
      return Container(
          height: 150,
          width: double.infinity,
          child: Swiper(
              indicatorLayout: PageIndicatorLayout.NONE,
              // viewportFraction: 0.8,
              loop: false,
              pagination: const SwiperPagination(
                  builder: DotSwiperPaginationBuilder(
                      color: Color.fromRGBO(7, 6, 6, 1),
                      size: 8,
                      activeSize: 10.0,
                      activeColor: Color.fromRGBO(208, 104, 39, 1))),
              // control: const SwiperControl(),
              itemCount: value.bannerList.length,
              itemBuilder: (context, index) {
                return Container(
                  child: Image.network(
                    value.bannerList[index].imgAddr,
                    fit: BoxFit.cover,
                  ),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    // color: Colors.blue,
                  ),
                  margin: const EdgeInsets.all(10),
                  height: 150,
                  // color: Colors.lightBlue,
                );
              }));
    });
  }

  //签到，福利兑换，攻略集锦
  Widget _toolBar() {
    return Row(
      children: [
        Column(
          children: [
            Stack(
              children: [
                Image.asset(
                  "assets/sign-in.png",
                  height: 62,
                ),
                Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                          color: Colors.red, shape: BoxShape.circle),
                    ))
              ],
            ),
            const Text("签到")
          ],
        ),
        Expanded(child: SizedBox()),
        Column(
          children: [
            Image.asset(
              "assets/shop.png",
              height: 62,
            ),
            Text("福利兑换")
          ],
        ),
        Expanded(child: SizedBox()),
        Column(
          children: [
            Image.asset(
              "assets/strategy.png",
              height: 62,
            ),
            Text("攻略集锦")
          ],
        ),
        Expanded(child: SizedBox()),
        Column(
          children: [
            Image.asset(
              "assets/data.png",
              height: 62,
            ),
            Text("游戏数据")
          ],
        )
      ],
    );
  }

  //帖子列表
  Widget _topicListBuilder() {
    return Consumer<HomePageRequest>(builder: (context, value, child) {
      return ListView.builder(
          itemBuilder: (context, index) {
            return _topicBuilder(value.topicList[index]);
          },
          // itemCount: 3,
          itemCount: value.topicList.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics());
    });
  }

  //帖子
  Widget _topicBuilder(Topic topic) {
    return GestureDetector(
        onTap: () {
          RouteUtils.push(
              context,
              const WebViewPage(
                title: "2132",
              ));
          // Navigator.pushNamed(context, RoutePath.webViewPage,arguments: RouteSettings(arguments: "String")   );
          // Navigator.push(context, MaterialPageRoute(builder: (context) {
          //   return const WebViewPage(title: "31174");
          // }));
        },
        child: Container(
            margin: const EdgeInsets.only(top: 15, right: 15, left: 15),
            color: Colors.white,
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipOval(
                        child: Image.network(
                      // "https://community.cdn.sunborngame.com/prod/1728031565956.jpeg",
                      topic.userAvatar,
                      width: 50,
                      height: 50,
                    )),
                    const SizedBox(
                      width: 15,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Text(
                            topic.userNickName,
                            // "作者",
                            style: TextStyle(fontSize: 20),
                          ),
                        ]),
                        Text(
                          topic.createTime,
                          style: TextStyle(color: Colors.grey),
                        )
                      ],
                    ),
                    Spacer(),
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(
                              color: Color.fromRGBO(246, 153, 97, 1),
                              width: 2)),
                      child: const Text(
                        "+ 关注",
                        style:
                            TextStyle(color: Color.fromRGBO(246, 153, 97, 1)),
                      ),
                    )
                  ],
                ),
                Text(
                  topic.title,
                  style: const TextStyle(
                    fontSize: 17,
                  ),
                  overflow: TextOverflow.ellipsis,
                ), // 标题
                Text(topic.content,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color.fromRGBO(153, 156, 159, 1),
                    ),
                    overflow: TextOverflow.ellipsis), // 内容
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    ...List.generate(topic.picList.length, (index) {
                      double rightMargin =
                          index == topic.picList.length - 1 ? 0 : 10;
                      return Flexible(
                          child: Container(
                        constraints: const BoxConstraints(
                          maxHeight: 260,
                        ),
                        margin: EdgeInsets.symmetric(vertical: 10)
                            .add(EdgeInsets.only(right: rightMargin)),
                        child: Image.network(
                          topic.picList[index],
                          // width: 100,
                          // height: 100,
                          // fit: BoxFit.fitWidth,
                        ),
                      ));
                    })
                  ],
                ), // 预览图片
                Row(
                  children: [
                    Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: const Color.fromRGBO(234, 234, 234, 1),
                        ),
                        child: Row(
                          children: [
                            Text(
                              topic.categoryName,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Color.fromRGBO(163, 163, 187, 1),
                              ),
                            ),
                          ],
                        )),
                    ...List.generate(topic.themeInfo.length, (index) {
                      return Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: const Color.fromRGBO(234, 234, 234, 1),
                          ),
                          child: Row(
                            children: [
                              Text(
                                "#${topic.themeInfo[index].themeName}",
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Color.fromRGBO(163, 163, 187, 1),
                                ),
                              ),
                            ],
                          ));
                    }),
                  ],
                ), // 话题标签
                Row(
                  children: [
                    const Expanded(child: SizedBox()),
                    Image.asset(
                      "assets/comments.png",
                      width: 23,
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 5),
                      child: Text(
                        topic.commentNum.toString(),
                        style: TextStyle(fontSize: 17, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Image.asset(
                      "assets/likes.png",
                      width: 23,
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 5),
                      child: Text(
                        topic.likeNum.toString(),
                        style: TextStyle(fontSize: 17, color: Colors.grey),
                      ),
                    ),
                  ],
                ), // 评论数，点赞数
              ],
            )));
  }
}
