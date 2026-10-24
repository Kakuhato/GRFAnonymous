import 'home_feed_filters.dart';
import 'home_official_card.dart';
import 'home_announcements.dart';
import 'package:grfanonymous/models/top_topic.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:grfanonymous/models/bannerItem.dart';
import 'package:grfanonymous/models/topicList.dart';
import 'package:grfanonymous/pageRequest/requestUtils.dart';

import 'home_banner.dart';
import 'home_categories.dart';
import 'home_shortcuts.dart';
import 'home_topic_card.dart';

/// 首页内容与滚动交互。数据请求和页面跳转由父页面通过回调提供。
class HomeFeed extends StatefulWidget {
  const HomeFeed({
    super.key,
    required this.category,
    required this.sort,
    required this.officialSubId,
    required this.onSortSelected,
    required this.onOfficialSubSelected,
    required this.onCategorySelected,
    required this.isSwitchingCategory,
    required this.banners,
    required this.topics,
    required this.announcements,
    required this.onOpenAnnouncement,
    required this.isSignedIn,
    this.isSigningIn = false,
    required this.onRefresh,
    required this.onLoad,
    required this.onSignIn,
    required this.onShop,
    required this.onGameData,
    required this.onOpenTopic,
    required this.onFollow,
    required this.onLike,
  });

  final List<BannerItem> banners;
  final CategoryId category;
  final SortType sort;
  final int officialSubId;
  final ValueChanged<SortType> onSortSelected;
  final ValueChanged<int> onOfficialSubSelected;
  final ValueChanged<CategoryId> onCategorySelected;
  final bool isSwitchingCategory;
  final List<Topic> topics;
  final List<TopTopic> announcements;
  final ValueChanged<int> onOpenAnnouncement;
  final bool isSignedIn;
  final bool isSigningIn;
  final Future<IndicatorResult> Function() onRefresh;
  final Future<IndicatorResult> Function() onLoad;
  final VoidCallback onSignIn;
  final VoidCallback onShop;
  final VoidCallback onGameData;
  final ValueChanged<Topic> onOpenTopic;
  final ValueChanged<Topic> onFollow;
  final ValueChanged<Topic> onLike;

  @override
  State<HomeFeed> createState() => _HomeFeedState();
}

class _HomeFeedState extends State<HomeFeed> {
  final _scrollController = ScrollController();
  final _refreshController = EasyRefreshController();
  final _showTopButton = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    _showTopButton.value = _scrollController.offset > 150;
  }

  @override
  void didUpdateWidget(covariant HomeFeed oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category != widget.category ||
        oldWidget.sort != widget.sort ||
        oldWidget.officialSubId != widget.officialSubId) {
      // 只重置分页状态，保留分类栏及其横向滚动位置。
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _refreshController.resetFooter();
      });
    }
  }

  void _scrollToTop() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuint,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _refreshController.dispose();
    _showTopButton.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        EasyRefresh(
          controller: _refreshController,
          triggerAxis: Axis.vertical,
          header: const MaterialHeader(),
          onRefresh: widget.onRefresh,
          onLoad: widget.onLoad,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: HomeBanner(banners: widget.banners)),
              SliverToBoxAdapter(
                child: HomeShortcuts(
                  isSignedIn: widget.isSignedIn,
                  isSigningIn: widget.isSigningIn,
                  onSignIn: widget.onSignIn,
                  onShop: widget.onShop,
                  onGameData: widget.onGameData,
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _CategoryHeaderDelegate(
                  height: 30 + MediaQuery.textScalerOf(context).scale(14) * 1.5,
                  selected: widget.category,
                  onSelected: widget.onCategorySelected,
                  onScrollToTop: _scrollToTop,
                ),
              ),
              SliverToBoxAdapter(
                child: HomeAnnouncements(
                  items: widget.announcements,
                  onOpen: widget.onOpenAnnouncement,
                ),
              ),
              SliverToBoxAdapter(
                child: HomeFeedFilters(
                  official: widget.category == CategoryId.official,
                  sort: widget.sort,
                  subId: widget.officialSubId,
                  onSort: widget.onSortSelected,
                  onSubSelected: widget.onOfficialSubSelected,
                ),
              ),
              if (widget.isSwitchingCategory)
                const SliverToBoxAdapter(child: LinearProgressIndicator()),
              if (widget.topics.isEmpty && !widget.isSwitchingCategory)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: Text('暂无帖子，下拉刷新重试')),
                  ),
                ),
              SliverList.builder(
                itemCount: widget.topics.length,
                itemBuilder: (context, index) {
                  final topic = widget.topics[index];
                  if (widget.category == CategoryId.official) {
                    return HomeOfficialCard(
                      topic: topic,
                      isActivity: widget.officialSubId == 1,
                      onOpen: () => widget.onOpenTopic(topic),
                    );
                  }
                  return HomeTopicCard(
                    topic: topic,
                    onOpen: () => widget.onOpenTopic(topic),
                    onFollow: () => widget.onFollow(topic),
                    onLike: () => widget.onLike(topic),
                  );
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: ValueListenableBuilder<bool>(
            valueListenable: _showTopButton,
            builder: (context, visible, child) =>
                visible ? child! : const SizedBox.shrink(),
            child: FloatingActionButton(
              onPressed: _scrollToTop,
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Image.asset(
                'assets/top.png',
                width: 100,
                fit: BoxFit.fitHeight,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 同一个分类栏随 Sliver 吸顶，不创建覆盖层或第二份横向滚动状态。
class _CategoryHeaderDelegate extends SliverPersistentHeaderDelegate {
  _CategoryHeaderDelegate({required this.height, required this.selected,
    required this.onSelected, required this.onScrollToTop});

  final double height;
  final CategoryId selected;
  final ValueChanged<CategoryId> onSelected;
  final VoidCallback onScrollToTop;

  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(
      child: HomeCategories(
        selected: selected,
        onSelected: (category) {
          if (shrinkOffset > 0 || overlapsContent) onScrollToTop();
          onSelected(category);
        },
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _CategoryHeaderDelegate oldDelegate) =>
      height != oldDelegate.height || selected != oldDelegate.selected ||
      onSelected != oldDelegate.onSelected || onScrollToTop != oldDelegate.onScrollToTop;
}
