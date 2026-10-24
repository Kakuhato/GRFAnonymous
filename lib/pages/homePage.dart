import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:grfanonymous/models/topicList.dart';
import 'package:grfanonymous/pageRequest/homeRequest.dart';
import 'package:grfanonymous/pageRequest/requestUtils.dart';
import 'package:grfanonymous/pageRequest/likeAndFollow.dart';
import 'package:grfanonymous/pages/shopPage.dart';
import 'search_page.dart';
import 'game_data_page.dart';
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
  bool _isFeedBusy = false;
  bool _isSwitchingCategory = false;
  CategoryId _category = CategoryId.recommend;
  SortType _sort = SortType.reply;
  int _officialSubId = 1;

  @override
  void initState() {
    super.initState();
    refreshData();
  }

  Future<IndicatorResult> refreshData() async {
    if (_isFeedBusy) return IndicatorResult.fail;
    _isFeedBusy = true;
    try {
      await Future.wait<void>([
        () async {
          await homePageRequest.getBanner();
          await homePageRequest.getTopic(category_id: _category,
              sort_type: _sort, category_sub_id: _officialSubId);
        }(),
        () async {
          await likeAndFollow.getSignInStatus();
          if (mounted) setState(() {});
        }(),
      ]);
      return IndicatorResult.success;
    } catch (_) {
      return IndicatorResult.fail;
    } finally {
      _isFeedBusy = false;
      if (mounted) setState(() {});
    }
  }

  Future<IndicatorResult> loadData() async {
    if (_isFeedBusy) return IndicatorResult.fail;
    if (!homePageRequest.nextPage) return IndicatorResult.noMore;
    _isFeedBusy = true;
    try {
      await homePageRequest.getTopic(onLoad: true);
      if (mounted) setState(() {});
      return homePageRequest.nextPage
          ? IndicatorResult.success
          : IndicatorResult.noMore;
    } catch (_) {
      return IndicatorResult.fail;
    } finally {
      _isFeedBusy = false;
    }
  }

  Future<void> _selectCategory(CategoryId category) async {
    if (category == _category) return;
    await _changeFeed(category: category, subId: 1);
  }

  Future<void> _changeFeed({CategoryId? category, SortType? sort, int? subId}) async {
    if (_isFeedBusy) {
      showToast('正在加载，请稍后切换');
      return;
    }
    final targetCategory = category ?? _category;
    final targetSort = sort ?? _sort;
    final targetSubId = subId ?? _officialSubId;
    if (targetCategory == _category && targetSort == _sort &&
        targetSubId == _officialSubId) return;
    _isFeedBusy = true;
    setState(() => _isSwitchingCategory = true);
    try {
      await homePageRequest.getTopic(category_id: targetCategory,
          sort_type: targetSort, category_sub_id: targetSubId);
      if (mounted) setState(() {
        _category = targetCategory;
        _sort = targetSort;
        _officialSubId = targetSubId;
      });
    } catch (_) {
      if (mounted) showToast('列表加载失败，请重试');
    } finally {
      _isFeedBusy = false;
      if (mounted) setState(() => _isSwitchingCategory = false);
    }
  }

  Future<void> _signIn() async {
    if (likeAndFollow.isSignIn) {
      showToast('今日已签到');
      return;
    }
    if (_isSigningIn) return;
    setState(() => _isSigningIn = true);
    try {
      final signedIn = await likeAndFollow.doSignIn();
      if (!mounted) return;
      if (signedIn) setState(() {});
    } catch (_) {
      if (mounted) showToast('签到失败，请重试');
    } finally {
      if (mounted) setState(() => _isSigningIn = false);
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
              tooltip: '搜索',
              onPressed: () => RouteUtils.push(context, const SearchPage()),
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
        category: _category,
        sort: _sort,
        officialSubId: _officialSubId,
        onSortSelected: (sort) => _changeFeed(sort: sort),
        onOfficialSubSelected: (subId) => _changeFeed(subId: subId),
        onCategorySelected: _selectCategory,
        isSwitchingCategory: _isSwitchingCategory,
        banners: homePageRequest.bannerList,
        topics: homePageRequest.topicList,
        announcements: homePageRequest.topTopics,
        onOpenAnnouncement: (topicId) => RouteUtils.push(
          context, WebViewPage(topicId: topicId.toString()),
        ),
        isSignedIn: likeAndFollow.isSignIn,
        isSigningIn: _isSigningIn,
        onRefresh: refreshData,
        onLoad: loadData,
        onSignIn: _signIn,
        onShop: () => RouteUtils.push(context, const ShopPage()),
        onGameData: () => RouteUtils.push(context, const GameDataPage()),
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

