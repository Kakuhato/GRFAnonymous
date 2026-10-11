import 'widgets/home_topic_card.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:grfanonymous/pageRequest/followPageRequest.dart';
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
  EasyRefreshController easyRefreshController = EasyRefreshController();
  ScrollController scrollController = ScrollController();

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
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              color: Colors.white,
              onPressed: () {
                easyRefreshController.callRefresh(scrollController: scrollController);
              },
            ),
          ],
          backgroundColor: Colors.black,
          title: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(left: 45),
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
        controller: easyRefreshController,
        triggerAxis: Axis.vertical,
        header: const MaterialHeader(),
        // footer: const CupertinoFooter(),
        // refreshOnStart: true,
        onRefresh: () async {
          await refreshData();
        },
        onLoad: () async {
          await loadData();
        },

        child: NestedScrollView(
          // controller: scrollController,
          headerSliverBuilder:
              (BuildContext context, bool innerBoxIsScrolled) => [
            const SliverToBoxAdapter(),
          ],
          body: Column(
            children: [
              Flexible(
                child: _topicListBuilder(),
              ),
              if (!followPageRequest.nextPage ||
                  followPageRequest.topicList.isEmpty)
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
      ),
    );
  }

  Widget _topicListBuilder() {
    return ListView.builder(
      controller: scrollController,
      itemBuilder: (context, index) {
        return _topicBuilder(followPageRequest.topicList[index]);
      },
      itemCount: followPageRequest.topicList.length,
      shrinkWrap: true,
      // physics: const NeverScrollableScrollPhysics(),
    );
  }

  Widget _topicBuilder(Topic topic) {
    return HomeTopicCard(
      topic: topic,
      showFollowButton: false,
      onOpen: () => RouteUtils.push(
        context,
        WebViewPage(topicId: topic.topicId.toString()),
      ),
      onLike: () => _like(topic),
    );
  }

  Future<void> _like(Topic topic) async {
    final result = await likeAndFollow.like(topic.topicId.toString());
    if (!result || !mounted) return;
    setState(() {
      topic.isLike = !topic.isLike;
      topic.likeNum += topic.isLike ? 1 : -1;
    });
    showToast(topic.isLike ? '点赞成功' : '取消点赞');
  }
}
