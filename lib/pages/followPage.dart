import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:grfanonymous/pageRequest/followPageRequest.dart';
import 'package:grfanonymous/pageRequest/requestUtils.dart';
import 'package:grfanonymous/pages/webViewPage.dart';
import 'package:oktoast/oktoast.dart';

import '../models/topicList.dart';
import '../pageRequest/likeAndFollow.dart';
import '../ui/uiSizeUtil.dart';
import '../utils/routeUtil.dart';

class FollowPage extends StatefulWidget {
  const FollowPage({super.key});

  @override
  State createState() => _FollowPageState();
}

class _FollowPageState extends State<FollowPage> {
  FollowPageRequest followPageRequest = FollowPageRequest();
  LikeAndFollow likeAndFollow = LikeAndFollow();

  @override
  void initState() {
    refreshData();
    super.initState();
  }

  Future<IndicatorResult> refreshData() async {
    await followPageRequest.getTopic(onLoad: false);
    setState(() {});
    return IndicatorResult.success;
  }

  Future<IndicatorResult> loadData() async {
    await followPageRequest.getTopic(onLoad: true);
    setState(() {});
    return IndicatorResult.success;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(UiSizeUtil.headerHeight),
        child: AppBar(
          backgroundColor: Colors.black,
          title: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(left: 0),
              child: Text(
                "关  注",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: UiSizeUtil.headerFontSize,
                ),
              )),
        ),
      ),
      backgroundColor: const Color.fromRGBO(245, 245, 245, 1),
      body: EasyRefresh(
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
          headerSliverBuilder:
              (BuildContext context, bool innerBoxIsScrolled) => [
            const SliverToBoxAdapter(),
            const SliverToBoxAdapter(),
          ],
          body: _topicListBuilder(),
        ),
      ),
    );
  }

  Widget _topicListBuilder() {
    return ListView.builder(
      itemBuilder: (context, index) {
        return _topicBuilder(followPageRequest.topicList[index]);
      },
      itemCount: followPageRequest.topicList.length,
      shrinkWrap: true,
      // physics: const NeverScrollableScrollPhysics(),
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
                ),
              ],
            ), // 评论数，点赞数
          ],
        ),
      ),
    );
  }
}
