import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/scheduler.dart';
import 'package:grfanonymous/models/topicList.dart';
import 'package:grfanonymous/pageRequest/homeRequest.dart';
import 'package:grfanonymous/pageRequest/likeAndFollow.dart';
import 'package:grfanonymous/pages/shopPage.dart';
import 'package:grfanonymous/pages/webViewPage.dart';
import 'package:grfanonymous/ui/uiSizeUtil.dart';
import 'package:grfanonymous/utils/routeUtil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:easy_refresh/easy_refresh.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

// extension fff on int{
//   double get d => toDouble();
//
//   double toD(){
//     return toDouble();
//   }
// }

class HomePageState extends State<HomePage> {
  HomePageRequest homePageRequest = HomePageRequest();
  LikeAndFollow likeAndFollow = LikeAndFollow();
  ScrollController _scrollController = ScrollController();
  bool _isShowTopButton = false;

  @override
  void initState() {
    refreshData();

    _scrollController.addListener(() {
      if (_scrollController.offset > 150 && !_isShowTopButton) {
        setState(() {
          _isShowTopButton = true;
        });
      } else if (_scrollController.offset <= 150 && _isShowTopButton) {
        // 当页面回到顶部，隐藏按钮
        setState(() {
          _isShowTopButton = false;
        });
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<IndicatorResult> refreshData() async {
    await homePageRequest.getBanner();
    await homePageRequest.getTopic();
    await likeAndFollow.getSignInStatus();
    setState(() {});
    return IndicatorResult.success;
  }

  Future<IndicatorResult> loadData() async {
    await homePageRequest.getTopic(onLoad: true);
    setState(() {});
    return IndicatorResult.success;
  }

  @override
  Widget build(BuildContext context) {
    // super.build(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(UiSizeUtil.headerHeight),
        child: AppBar(
          backgroundColor: Colors.black,
          title: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(left: 45),
              child: Text(
                "主  页",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: UiSizeUtil.headerFontSize,
                ),
              )),
          actions: [
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.search,
                color: Colors.white,
                size: UiSizeUtil.topIconSize,
              ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color.fromRGBO(245, 245, 245, 1),
      body: Stack(
        children: [
          EasyRefresh(
            // scrollController: _scrollController,
            // scrollController: ScrollController(keepScrollOffset: false),
            triggerAxis: Axis.vertical,
            header: const MaterialHeader(),
            // footer: const CupertinoFooter(),
            // refreshOnStart: true,
            onRefresh: () async {
              return await refreshData();
            },
            onLoad: () async {
              return await loadData();
            },
            child: NestedScrollView(
              controller: _scrollController,
              // physics: const NeverScrollableScrollPhysics(),
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) => [
                SliverToBoxAdapter(
                  child: _bannerBuilder(),
                ),
                SliverToBoxAdapter(
                  child: _toolBar(), //导航栏
                ),
              ],
              body: _topicListBuilder(),
            ),
          ),
          if (_isShowTopButton)
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                onPressed: () {
                  if (_scrollController.hasClients) {
                    SchedulerBinding.instance.addPostFrameCallback((_) {
                      _scrollController.animateTo(
                        0, // 滚动到顶部
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutQuint,
                      );
                    });
                  }
                },
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: Image.asset(
                  "assets/top.png",
                  width: 100,
                  fit: BoxFit.fitHeight,
                ), // 去除阴影
              ),
            ),
        ],
      ),
    );
  }

  Widget _bannerBuilder() {
    return SizedBox(
      height: 150,
      width: double.infinity,
      child: Swiper(
        autoplay: true,
        viewportFraction: 1,
        loop: false,
        physics: const BouncingScrollPhysics(),
        pagination: const SwiperPagination(
            builder: DotSwiperPaginationBuilder(
                color: Color.fromRGBO(7, 6, 6, 1),
                size: 8,
                activeSize: 10.0,
                activeColor: Color.fromRGBO(208, 104, 39, 1))),
        // control: const SwiperControl(),
        itemCount: homePageRequest.bannerList.length,
        itemBuilder: (context, index) {
          return Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              // color: Colors.blue,
            ),
            margin: const EdgeInsets.all(10),
            height: 150,
            child: CachedNetworkImage(
              imageUrl: homePageRequest.bannerList[index].imgAddr,
              fit: BoxFit.cover,
            ),
            // color: Colors.lightBlue,
          );
        },
      ),
    );
  }

  //签到，福利兑换，攻略集锦
  Widget _toolBar() {
    return Container(
      height: 110,
      width: double.infinity,
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
      margin: const EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        // border: Border.all(color: Colors.grey)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Stack(
                children: [
                  GestureDetector(
                    onTap: () async {
                      likeAndFollow.isSignIn = await likeAndFollow.doSignIn();
                      setState(() {});
                    },
                    child: Image.asset(
                      likeAndFollow.isSignIn
                          ? "assets/sign-in-ed.png"
                          : "assets/sign-in.png",
                      height: 62,
                    ),
                  ),
                  Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: likeAndFollow.isSignIn
                              ? const Color.fromRGBO(244, 67, 54, 0)
                              : Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ))
                ],
              ),
              const Text("签到")
            ],
          ),
          Column(
            children: [
              GestureDetector(
                onTap: () {
                  RouteUtils.push(context, const ShopPage());
                },
                child: Image.asset(
                  "assets/shop.png",
                  height: 62,
                ),
              ),
              Text("福利兑换")
            ],
          ),
          Column(
            children: [
              Image.asset(
                "assets/strategy.png",
                height: 62,
              ),
              Text("攻略集锦")
            ],
          ),
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
      ),
    );
  }

  //帖子列表
  Widget _topicListBuilder() {
    return ListView.builder(
      itemBuilder: (context, index) {
        return _topicBuilder(homePageRequest.topicList[index]);
      },
      itemCount: homePageRequest.topicList.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
    );
  }

  //帖子
  Widget _topicBuilder(Topic topic) {
    return GestureDetector(
      onTap: () {
        RouteUtils.push(
          context,
          WebViewPage(
            topicId: topic.topicId.toString(),
          ),
        );
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
                    child: CachedNetworkImage(
                  imageUrl: topic.userAvatar,
                  width: UiSizeUtil.homePageAvatarSize,
                  height: UiSizeUtil.homePageAvatarSize,
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
                        style: TextStyle(
                          fontSize: UiSizeUtil.homePageUserNameFontSize,
                          // fontWeight: FontWeight.bold,
                        ),
                      ),
                    ]),
                    Text(
                      topic.createTime,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: UiSizeUtil.homePageTimeFontSize,
                      ),
                    )
                  ],
                ),
                Spacer(),
                GestureDetector(
                  onTap: () async {
                    bool result = await likeAndFollow.follow(topic.userId);
                    if (result) {
                      setState(() {
                        topic.isFollow = !topic.isFollow;
                      });
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(
                        color: topic.isFollow
                            ? Colors.grey
                            : const Color.fromRGBO(246, 153, 97, 1),
                        width: topic.isFollow ? 1 : 2,
                      ),
                    ),
                    child: topic.isFollow
                        ? const Text(
                            "已关注",
                            style: TextStyle(color: Colors.grey),
                          )
                        : const Text(
                            "+ 关注",
                            style: TextStyle(
                              color: Color.fromRGBO(246, 153, 97, 1),
                            ),
                          ),
                  ),
                )
              ],
            ),
            Text(
              topic.title,
              style: TextStyle(
                fontSize: UiSizeUtil.homePageTitleFontSize,
              ),
              overflow: TextOverflow.ellipsis,
            ), // 标题
            Text(
              topic.content,
              style: TextStyle(
                fontSize: UiSizeUtil.homePageContentFontSize,
                color: const Color.fromRGBO(153, 156, 159, 1),
              ),
              overflow: TextOverflow.ellipsis,
            ), // 内容
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
                    child: CachedNetworkImage(
                      imageUrl: topic.picList[index],
                      // width: 100,
                      // height: 100,
                      // fit: BoxFit.cover,
                    ),
                  ));
                })
              ],
            ),
            Wrap(
              children: [
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color.fromRGBO(234, 234, 234, 1),
                  ),
                  child: Text(
                    topic.categoryName,
                    style: TextStyle(
                      fontSize: UiSizeUtil.tagFontSize,
                      color: Color.fromRGBO(163, 163, 187, 1),
                    ),
                  ),
                ),
                ...List.generate(topic.themeInfo.length, (index) {
                  return Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color.fromRGBO(234, 234, 234, 1),
                    ),
                    child: Text(
                      "#${topic.themeInfo[index].themeName}",
                      style: TextStyle(
                        fontSize: UiSizeUtil.tagFontSize,
                        color: Color.fromRGBO(163, 163, 187, 1),
                      ),
                    ),
                    // Row(
                    //   children: [
                    //
                    //   ],
                    // )
                  );
                }),
              ],
            ), // 话题标签
            Row(
              children: [
                const Expanded(child: SizedBox()),
                Image.asset(
                  "assets/comments.png",
                  width: UiSizeUtil.likeIconSize,
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  child: Text(
                    topic.commentNum.toString(),
                    style: TextStyle(
                      fontSize: UiSizeUtil.likeFontSize,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                GestureDetector(
                  onTap: () async {
                    bool result =
                        await likeAndFollow.like(topic.topicId.toString());
                    if (result) {
                      setState(() {
                        topic.isLike = !topic.isLike;
                        if (topic.isLike) {
                          topic.likeNum++;
                        } else {
                          topic.likeNum--;
                        }
                      });
                      showToast(topic.isLike ? "点赞成功" : "取消点赞");
                    }
                  },
                  child: Row(
                    children: [
                      Image.asset(
                        topic.isLike ? "assets/liked.png" : "assets/likes.png",
                        width: UiSizeUtil.likeIconSize,
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        child: Text(
                          topic.likeNum.toString(),
                          style: TextStyle(
                            fontSize: UiSizeUtil.likeFontSize,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ), // 评论数，点赞数
          ],
        ),
      ),
    );
  }

  void updateLikeState(
    int topicID,
    bool islike,
  ) {
    for (var topic in homePageRequest.topicList) {
      if (topic.topicId == topicID) {
        topic.isLike = islike;
        if (islike) {
          topic.likeNum++;
        } else {
          topic.likeNum--;
        }
      }
    }
    setState(() {});
  }

  void updateFollowState(int userID, bool isFollow) {
    for (var topic in homePageRequest.topicList) {
      if (topic.userId == userID) {
        topic.isFollow = isFollow;
      }
    }
    setState(() {});
  }

}
