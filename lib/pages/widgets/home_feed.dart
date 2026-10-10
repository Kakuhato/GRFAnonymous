import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:grfanonymous/models/bannerItem.dart';
import 'package:grfanonymous/models/topicList.dart';

import 'home_banner.dart';
import 'home_shortcuts.dart';
import 'home_topic_card.dart';

/// 首页内容与滚动交互。数据请求和页面跳转由父页面通过回调提供。
class HomeFeed extends StatefulWidget {
  const HomeFeed({
    super.key,
    required this.banners,
    required this.topics,
    required this.isSignedIn,
    required this.onRefresh,
    required this.onLoad,
    required this.onSignIn,
    required this.onShop,
    required this.onOpenTopic,
    required this.onFollow,
    required this.onLike,
  });

  final List<BannerItem> banners;
  final List<Topic> topics;
  final bool isSignedIn;
  final Future<IndicatorResult> Function() onRefresh;
  final Future<IndicatorResult> Function() onLoad;
  final VoidCallback onSignIn;
  final VoidCallback onShop;
  final ValueChanged<Topic> onOpenTopic;
  final ValueChanged<Topic> onFollow;
  final ValueChanged<Topic> onLike;

  @override
  State<HomeFeed> createState() => _HomeFeedState();
}

class _HomeFeedState extends State<HomeFeed> {
  final _scrollController = ScrollController();
  final _showTopButton = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    _showTopButton.value = _scrollController.offset > 150;
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
    _showTopButton.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        EasyRefresh(
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
                  onSignIn: widget.onSignIn,
                  onShop: widget.onShop,
                ),
              ),
              SliverList.builder(
                itemCount: widget.topics.length,
                itemBuilder: (context, index) {
                  final topic = widget.topics[index];
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
