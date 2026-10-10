import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:grfanonymous/models/topicList.dart';
import 'package:grfanonymous/pageRequest/homeRequest.dart';
import 'package:grfanonymous/pageRequest/likeAndFollow.dart';
import 'package:grfanonymous/pages/shopPage.dart';
import 'package:grfanonymous/pages/webViewPage.dart';
import 'package:grfanonymous/pages/widgets/home_feed.dart';
import 'package:grfanonymous/ui/uiSizeUtil.dart';
import 'package:grfanonymous/utils/routeUtil.dart';
import 'package:oktoast/oktoast.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final HomePageRequest homePageRequest = HomePageRequest();
  final LikeAndFollow likeAndFollow = LikeAndFollow();
  bool _isSigningIn = false;

  @override
  void initState() {
    super.initState();
    refreshData();
  }

  Future<IndicatorResult> refreshData() async {
    try {
      await homePageRequest.getBanner();
      await homePageRequest.getTopic();
      await likeAndFollow.getSignInStatus();
      return IndicatorResult.success;
    } catch (_) {
      return IndicatorResult.fail;
    } finally {
      if (mounted) setState(() {});
    }
  }

  Future<IndicatorResult> loadData() async {
    if (!homePageRequest.nextPage) return IndicatorResult.noMore;
    try {
      await homePageRequest.getTopic(onLoad: true);
      if (mounted) setState(() {});
      return homePageRequest.nextPage
          ? IndicatorResult.success
          : IndicatorResult.noMore;
    } catch (_) {
      return IndicatorResult.fail;
    }
  }

  Future<void> _signIn() async {
    if (_isSigningIn || likeAndFollow.isSignIn) return;
    _isSigningIn = true;
    try {
      final signedIn = await likeAndFollow.doSignIn();
      if (!mounted) return;
      setState(() => likeAndFollow.isSignIn = signedIn);
    } catch (_) {
      if (mounted) showToast('签到失败，请重试');
    } finally {
      _isSigningIn = false;
    }
  }

  Future<void> _follow(Topic topic) async {
    final result = await likeAndFollow.follow(topic.userId);
    if (!result || !mounted) return;
    updateFollowState(topic.userId, !topic.isFollow);
  }

  Future<void> _like(Topic topic) async {
    final result = await likeAndFollow.like(topic.topicId.toString());
    if (!result || !mounted) return;
    updateLikeState(topic.topicId, !topic.isLike);
    showToast(topic.isLike ? '点赞成功' : '取消点赞');
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
            padding: const EdgeInsets.only(left: 45),
            child: Text(
              '主  页',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: UiSizeUtil.headerFontSize,
              ),
            ),
          ),
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
      body: HomeFeed(
        banners: homePageRequest.bannerList,
        topics: homePageRequest.topicList,
        isSignedIn: likeAndFollow.isSignIn,
        onRefresh: refreshData,
        onLoad: loadData,
        onSignIn: _signIn,
        onShop: () => RouteUtils.push(context, const ShopPage()),
        onOpenTopic: (topic) => RouteUtils.push(
          context,
          WebViewPage(topicId: topic.topicId.toString()),
        ),
        onFollow: _follow,
        onLike: _like,
      ),
    );
  }

  // Detail and profile pages currently call these methods through homeScaffoldKey.
  void updateLikeState(int topicID, bool islike) {
    var changed = false;
    for (final topic in homePageRequest.topicList) {
      if (topic.topicId == topicID && topic.isLike != islike) {
        topic.isLike = islike;
        topic.likeNum += islike ? 1 : -1;
        changed = true;
      }
    }
    if (changed && mounted) setState(() {});
  }

  void updateFollowState(int userID, bool isFollow) {
    var changed = false;
    for (final topic in homePageRequest.topicList) {
      if (topic.userId == userID && topic.isFollow != isFollow) {
        topic.isFollow = isFollow;
        changed = true;
      }
    }
    if (changed && mounted) setState(() {});
  }
}

