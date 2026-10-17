import 'game_data_page.dart';
import 'package:grfanonymous/ui/image_gallery.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:grfanonymous/pageRequest/loginRequest.dart';
import 'package:grfanonymous/pageRequest/myPageRequest.dart';
import 'package:grfanonymous/pageRequest/requestUtils.dart';
import 'package:grfanonymous/pages/loginPage.dart';
import 'package:grfanonymous/pages/webViewPage.dart';
import 'package:grfanonymous/ui/bottomSheet.dart';
import 'package:grfanonymous/utils/routeUtil.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';

import '../models/topicList.dart';
import '../models/userData.dart';
import '../ui/uiSizeUtil.dart';
import '../utils/htmlUtil.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  MyPageRequest myPageRequest = MyPageRequest();
  bool _isLoading = true;

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    _refresh();
    // _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await myPageRequest.getUserData();
    await myPageRequest.getGameData();
    await myPageRequest.getOwnTopic(
      onLoad: false,
      sort_type: SortType.reply,
      category_id: CategoryId.none,
      query_type: QueryType.identity,
      user_id: 0,
    );
    await myPageRequest.getFavorTopic(
      onFresh: true,
      sortType: SortType.reply,
      categoryId: CategoryId.none,
      queryType: QueryType.favor,
      userId: 0,
    );
    await myPageRequest.getReply(
      onFresh: true,
      sortType: SortType.reply,
      categoryId: CategoryId.none,
      queryType: QueryType.favor,
      userId: 0,
    );
    setState(() {
      _isLoading = false;
    });
  }

  Future<IndicatorResult> loadOwnTopicData() async {
    await myPageRequest.getOwnTopic(
      onLoad: true,
      user_id: 0,
    );
    setState(() {});
    return IndicatorResult.success;
  }

  Future<IndicatorResult> loadFavorTopicData() async {
    await myPageRequest.getFavorTopic(
      onFresh: false,
      userId: 0,
    );
    setState(() {});
    return IndicatorResult.success;
  }

  Future<IndicatorResult> loadReplyData() async {
    await myPageRequest.getReply(
      onFresh: false,
      userId: 0,
    );
    setState(() {});
    return IndicatorResult.success;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(UiSizeUtil.headerHeight),
        child: AppBar(
          leading: IconButton(
            onPressed: () {
              _refresh();
            },
            icon: Icon(
              Icons.refresh,
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  BottomSheetBuilder.showBottomSheet(
                    context,
                    backgroundColor: Colors.black,
                    (_) => Column(
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: ListTile(
                            // leading: const Icon(Icons.settings),
                            title: const Text(
                              "退出登录",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ),
                            onTap: () {
                              RouteUtils.pushAndRemove(
                                  context, const LoginPage());
                              LoginRequest.exit();
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
                icon: Icon(
                  Icons.settings_outlined,
                  color: Colors.white,
                  size: UiSizeUtil.topIconSize,
                ))
          ],
          title: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(right: 10),
              child: Text(
                "我  的",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: UiSizeUtil.headerFontSize,
                ),
              )),
          backgroundColor: Colors.black,
        ),
      ),
      backgroundColor: const Color.fromRGBO(245, 245, 245, 1),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) => [
                SliverToBoxAdapter(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // 背景原图 750 × 377，头像和资料随背景高度定位。
                      final backgroundHeight =
                          (constraints.maxWidth - 20) * 377 / 750;
                      final profileTop = backgroundHeight - 40;
                      return Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: AspectRatio(
                              aspectRatio: 750 / 377,
                              child: CachedNetworkImage(
                                imageUrl:
                                    "https://gf2-cn.cdn.sunborngame.com/website/official/source/bbsm1727171280566/img/mine_bg.91cacca5.png",
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          _profileBuilder(profileTop),
                          Positioned(
                            top: profileTop - UiSizeUtil.userAvatarSize / 2,
                            left: 40,
                            child: ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: myPageRequest.userData.avatar,
                                fit: BoxFit.cover,
                                width: UiSizeUtil.userAvatarSize,
                                height: UiSizeUtil.userAvatarSize,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => RouteUtils.push(context, const GameDataPage()),
                    child: _gameInfo(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    // color: Colors.white,
                    child: TabBar(
                      controller: _tabController,
                      indicatorColor: Colors.orange,
                      labelColor: Colors.orange,
                      unselectedLabelColor: Colors.grey,
                      tabs: const [
                        Tab(text: "帖子"),
                        Tab(text: "评论"),
                        Tab(text: "收藏"),
                      ],
                    ),
                  ), //导航栏
                ),
              ],
              body: TabBarView(
                controller: _tabController,
                children: [
                  _topicList(),
                  _commentList(),
                  _favorList(),
                ],
              ),
            ),
    );
  }

  Widget _profileBuilder(double top) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20)
          .add(EdgeInsets.only(top: top)),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                myPageRequest.userData.nickName,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: UiSizeUtil.userUserNameFontSize,
                ),
              ),
              if (myPageRequest.userData.endlessRank > 0)
                Tooltip(
                  message: '无尽模式排名：${myPageRequest.userData.endlessRank}',
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9EBED),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.military_tech,
                            size: 14, color: Color(0xFF8B8070)),
                        Text(
                          '${myPageRequest.userData.endlessFloor < 0 ? 0 : myPageRequest.userData.endlessFloor}层',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          //ip属地，社区id
          Wrap(
            spacing: 16,
            runSpacing: 4,
            children: [
              Text(
                "ip属地：${myPageRequest.userData.ipLocation}",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: UiSizeUtil.userIdFontSize,
                ),
              ),
              Text(
                "社区ID：${myPageRequest.userData.uid}",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: UiSizeUtil.userIdFontSize,
                ),
              ),
            ],
          ),
          _fansAndFollow(),
        ],
      ),
    );
  }

  Widget _fansAndFollow() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
      decoration: const BoxDecoration(
        color: Color.fromRGBO(242, 242, 242, 1),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceAround,
        spacing: 12,
        runSpacing: 8,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                myPageRequest.userData.fans.toString(),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: UiSizeUtil.userFansNumFontSize,
                ),
              ),
              Text(
                "粉丝",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: UiSizeUtil.userFansFontSize,
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                myPageRequest.userData.follows.toString(),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: UiSizeUtil.userFansNumFontSize,
                ),
              ),
              Text(
                "关注",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: UiSizeUtil.userFansFontSize,
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                myPageRequest.userData.likes,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: UiSizeUtil.userFansNumFontSize,
                ),
              ),
              Text(
                "获赞",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: UiSizeUtil.userFansFontSize,
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                myPageRequest.userData.favors.toString(),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: UiSizeUtil.userFansNumFontSize,
                ),
              ),
              Text(
                "收藏",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: UiSizeUtil.userFansFontSize,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _gameInfo() {
    // 使用原图比例布局；文字和头像与背景一起缩放，避免固定宽度裁切。
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: AspectRatio(
        aspectRatio: 1380 / 568,
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: 460,
            height: 568 / 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl:
                      "https://gf2-cn.cdn.sunborngame.com/website/official/source/bbsm1727171280566/img/data_bg.e722b1ec.png",
                  fit: BoxFit.contain,
                ),
                Positioned(
                  left: 20,
                  top: 32,
                  width: 270,
                  bottom: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CachedNetworkImage(
                            imageUrl: myPageRequest.gameData.userInfo.avatar,
                            height: 60,
                            width: 60,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  myPageRequest.gameData.userInfo.nickName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: UiSizeUtil.gameInfoCardUserNameFontSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${myPageRequest.gameData.userInfo.level}级',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: UiSizeUtil.gameInfoCardLevelFontSize,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            _buildInfoText(
                                myPageRequest.gameData.baseInfo.mainStage, '主线进度'),
                            const SizedBox(width: 16),
                            _buildInfoText(
                                myPageRequest.gameData.baseInfo.heroCount.toString(), '人形收集'),
                            const SizedBox(width: 16),
                            _buildInfoText(
                                myPageRequest.gameData.baseInfo.achievementCount.toString(), '里程碑'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoText(String value, String label) {
    // 资料卡以 460 宽为基准整体缩放，统计字号需预留手机端缩小的余量。
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ],
    );
  }

  Widget _topicList() {
    return EasyRefresh(
      header: const MaterialHeader(),
      onLoad: myPageRequest.ownTopicListParam.nextPage
          ? () async {
              await loadOwnTopicData();
              setState(() {});
            }
          : null,
      child: SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: myPageRequest.ownTopicList.length,
              itemBuilder: (context, index) {
                return _topic(myPageRequest.ownTopicList[index]);
              },
            ),
            if (!myPageRequest.ownTopicListParam.nextPage)
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 10),
                child: const Text(
                  "没有更多了",
                  style: TextStyle(
                    fontSize: 10,
                    color: Color.fromRGBO(150, 151, 153, 1),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _topic(Topic topic) {
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
                            fontSize: UiSizeUtil.homePageUserNameFontSize),
                      ),
                    ]),
                    Text(
                      topic.createTime,
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: UiSizeUtil.homePageTimeFontSize),
                    )
                  ],
                ),
                Spacer(),
                // Container(
                //   padding: EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                //   decoration: BoxDecoration(
                //       borderRadius: BorderRadius.circular(3),
                //       border: Border.all(
                //           color: Color.fromRGBO(246, 153, 97, 1), width: 2)),
                //   child: const Text(
                //     "+ 关注",
                //     style: TextStyle(color: Color.fromRGBO(246, 153, 97, 1)),
                //   ),
                // )
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
                color: Color.fromRGBO(153, 156, 159, 1),
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
                    child: GestureDetector(
                      onTap: () => showImageGallery(
                        context,
                        images: topic.picList,
                        initialIndex: index,
                      ),
                      child: CachedNetworkImage(
                        imageUrl: topic.picList[index],
                      ),
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
                Row(
                  children: [
                    Image.asset(
                      topic.isLike ? "assets/liked.png" : "assets/likes.png",
                      width: UiSizeUtil.likeIconSize,
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 5),
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
              ],
            ), // 评论数，点赞数
          ],
        ),
      ),
    );
  }

  Widget _commentList() {
    return EasyRefresh(
      header: const MaterialHeader(),
      onLoad: myPageRequest.replyListParam.nextPage
          ? () async {
              await loadReplyData();
              setState(() {});
            }
          : null,
      child: SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: myPageRequest.replyList.length,
              itemBuilder: (context, index) {
                return _comment(myPageRequest.replyList[index]);
              },
            ),
            if (!myPageRequest.replyListParam.nextPage)
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 10),
                child: const Text(
                  "没有更多了",
                  style: TextStyle(
                    fontSize: 10,
                    color: Color.fromRGBO(150, 151, 153, 1),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _comment(MyReply reply) {
    return GestureDetector(
      onTap: () {
        RouteUtils.push(
          context,
          WebViewPage(
            topicId: reply.topicId.toString(),
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
            HtmlWidget(
              reply.content,
              factoryBuilder: () => MyWidgetFactory(context),
              customStylesBuilder: (element) {
                return HtmlProcess.buildCustomStyles(element);
              },
              textStyle: TextStyle(
                fontSize: UiSizeUtil.postContentFontSize,
                color: Colors.black,
              ),
            ),
            Text(
              reply.createTime,
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: UiSizeUtil.homePageTimeFontSize),
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 5),
                    padding: const EdgeInsets.only(left: 10,top: 5,bottom: 5,),
                    color: const Color.fromRGBO(245, 245, 245, 1),
                    child: Text(
                      "回复帖子：${reply.title}",
                      style: TextStyle(
                        fontSize: UiSizeUtil.homePageContentFontSize,
                        color: const Color.fromRGBO(153, 156, 159, 1),
                        overflow: TextOverflow.ellipsis,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _favorList() {
    return EasyRefresh(
      header: const MaterialHeader(),
      onLoad: myPageRequest.favorTopicListParam.total !=
              myPageRequest.favorTopicList.length
          ? () async {
              await loadFavorTopicData();
              setState(() {});
            }
          : null,
      child: SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: myPageRequest.favorTopicList.length,
              itemBuilder: (context, index) {
                return _favor(myPageRequest.favorTopicList[index]);
              },
            ),
            if (myPageRequest.favorTopicListParam.total ==
                myPageRequest.favorTopicList.length)
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 10),
                child: const Text(
                  "没有更多了",
                  style: TextStyle(
                    fontSize: 10,
                    color: Color.fromRGBO(150, 151, 153, 1),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _favor(Topic topic) {
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
                            fontSize: UiSizeUtil.homePageUserNameFontSize),
                      ),
                    ]),
                    Text(
                      topic.createTime,
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: UiSizeUtil.homePageTimeFontSize),
                    )
                  ],
                ),
                Spacer(),
                // Container(
                //   padding: EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                //   decoration: BoxDecoration(
                //       borderRadius: BorderRadius.circular(3),
                //       border: Border.all(
                //           color: Color.fromRGBO(246, 153, 97, 1), width: 2)),
                //   child: const Text(
                //     "+ 关注",
                //     style: TextStyle(color: Color.fromRGBO(246, 153, 97, 1)),
                //   ),
                // )
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
                color: Color.fromRGBO(153, 156, 159, 1),
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
                    child: GestureDetector(
                      onTap: () => showImageGallery(
                        context,
                        images: topic.picList,
                        initialIndex: index,
                      ),
                      child: CachedNetworkImage(
                        imageUrl: topic.picList[index],
                      ),
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
                Row(
                  children: [
                    Image.asset(
                      topic.isLike ? "assets/liked.png" : "assets/likes.png",
                      width: UiSizeUtil.likeIconSize,
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 5),
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
              ],
            ), // 评论数，点赞数
          ],
        ),
      ),
    );
  }
}

