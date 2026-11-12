import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import '../models/topicList.dart';
import '../pageRequest/likeAndFollow.dart';
import '../pageRequest/theme_request.dart';
import '../ui/uiSizeUtil.dart';
import '../utils/routeUtil.dart';
import 'webViewPage.dart';
import 'widgets/home_topic_card.dart';

class ThemeDetailPage extends StatefulWidget {
  final int themeId;
  final String name;
  const ThemeDetailPage({super.key, required this.themeId, required this.name});

  @override
  State<ThemeDetailPage> createState() => _ThemeDetailPageState();
}

class _ThemeDetailPageState extends State<ThemeDetailPage> {
  final _request = ThemeRequest();
  final _actions = LikeAndFollow();
  final _scroll = ScrollController();
  final _showTopButton = ValueNotifier(false);
  final _pendingLikes = <int>{};
  final _pendingFollows = <int>{};
  ThemeDetail? _detail;
  List<Topic> _topics = [];
  Map<String, int> _cursor = {};
  int _sort = 1;
  int _page = 0;
  int _revision = 0;
  bool _loading = false;
  bool _hasMore = true;
  bool _detailLoading = false;
  String? _detailError;
  String? _listError;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _refresh();
  }

  @override
  void dispose() {
    _scroll.dispose();
    _showTopButton.dispose();
    super.dispose();
  }

  void _onScroll() {
    _showTopButton.value = _scroll.offset > 150;
    if (_scroll.position.extentAfter < 250 && !_loading && _hasMore && _listError == null) {
      _loadTopics();
    }
  }

  void _scrollToTop() {
    if (!_scroll.hasClients) return;
    _scroll.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuint,
    );
  }

  Future<void> _loadDetail() async {
    if (_detailLoading) return;
    setState(() { _detailLoading = true; _detailError = null; });
    try {
      final detail = await _request.detail(widget.themeId);
      if (mounted) setState(() => _detail = detail);
    } catch (_) {
      if (mounted) setState(() => _detailError = '话题简介加载失败，请重试');
    } finally {
      if (mounted) setState(() => _detailLoading = false);
    }
  }

  Future<void> _refresh() async {
    await Future.wait([_loadDetail(), _loadTopics(reset: true)]);
  }

  Future<void> _loadTopics({bool reset = false}) async {
    if (!reset && (_loading || !_hasMore)) return;
    final revision = ++_revision;
    final page = reset ? 1 : _page + 1;
    setState(() {
      _loading = true;
      _listError = null;
      if (reset) { _topics = []; _cursor = {}; _page = 0; _hasMore = true; }
    });
    try {
      final result = await _request.topics(widget.themeId,
          sort: _sort, page: page, cursor: reset ? const {} : _cursor);
      if (!mounted || revision != _revision) return;
      setState(() {
        final ids = _topics.map((topic) => topic.topicId).toSet();
        _topics.addAll(result.topics.where((topic) => ids.add(topic.topicId)));
        _cursor = result.cursor;
        _page = page;
        _hasMore = result.hasMore;
      });
    } catch (_) {
      if (mounted && revision == _revision) {
        setState(() => _listError = '帖子加载失败，请重试');
      }
    } finally {
      if (mounted && revision == _revision) setState(() => _loading = false);
    }
  }

  void _changeSort(int sort) {
    if (_sort == sort) return;
    setState(() => _sort = sort);
    if (_scroll.hasClients) _scroll.jumpTo(0);
    _loadTopics(reset: true);
  }

  Future<void> _like(Topic topic) async {
    if (!_pendingLikes.add(topic.topicId)) return;
    try {
      final success = await _actions.like('${topic.topicId}');
      if (!mounted) return;
      if (!success) { showToast('操作失败，请重试'); return; }
      setState(() {
        topic.isLike = !topic.isLike;
        if (topic.isLike) { topic.likeNum++; }
        else if (topic.likeNum > 0) { topic.likeNum--; }
      });
    } catch (_) {
      if (mounted) showToast('操作失败，请检查网络或登录状态');
    } finally { _pendingLikes.remove(topic.topicId); }
  }

  Future<void> _follow(Topic topic) async {
    if (!_pendingFollows.add(topic.userId)) return;
    try {
      final success = await _actions.follow(topic.userId);
      if (!mounted) return;
      if (!success) { showToast('操作失败，请重试'); return; }
      final followed = !topic.isFollow;
      setState(() {
        for (final item in _topics) {
          if (item.userId == topic.userId) item.isFollow = followed;
        }
      });
    } catch (_) {
      if (mounted) showToast('操作失败，请检查网络或登录状态');
    } finally { _pendingFollows.remove(topic.userId); }
  }

  Widget _header() {
    final detail = _detail;
    final name = detail?.name ?? widget.name;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF292929),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          if (detail != null && detail.image.isNotEmpty) ...[
            CachedNetworkImage(imageUrl: detail.image, width: 64, height: 64,
              fit: BoxFit.cover, errorWidget: (_, __, ___) => const Icon(Icons.tag, color: Colors.white)),
            const SizedBox(width: 12),
          ],
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name.startsWith('#') ? name : '#$name',
              style: TextStyle(color: Colors.white, fontSize: UiSizeUtil.homePageUserNameFontSize,
                fontWeight: FontWeight.bold)),
            if (detail != null) ...[
              const SizedBox(height: 8),
              Text('阅读：${detail.views}  |  讨论：${detail.discussions}',
                style: TextStyle(color: Colors.white70, fontSize: UiSizeUtil.homePageContentFontSize)),
            ],
          ])),
        ]),
        if (detail != null && detail.description.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(detail.description, style: TextStyle(color: Colors.white70,
            fontSize: UiSizeUtil.homePageContentFontSize)),
        ],
        if (_detailLoading) const LinearProgressIndicator(),
        if (_detailError != null)
          TextButton(onPressed: _loadDetail, child: Text(_detailError!, style: const TextStyle(color: Colors.orange))),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        toolbarHeight: UiSizeUtil.headerHeight,
        centerTitle: true, backgroundColor: Colors.black, foregroundColor: Colors.white,
        iconTheme: IconThemeData(size: UiSizeUtil.topIconSize, color: Colors.white),
        title: Text('话题详情', style: TextStyle(fontSize: UiSizeUtil.headerFontSize)),
      ),
      body: SafeArea(top: false, child: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              controller: _scroll, physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 16), itemCount: _topics.length + 3,
              itemBuilder: (context, index) {
                if (index == 0) return _header();
                if (index == 1) {
                  return Container(color: Colors.white, child: Row(children: [
                    for (final sort in [1, 3])
                      InkWell(onTap: () => _changeSort(sort), child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(border: Border(bottom: BorderSide(
                          color: _sort == sort ? const Color(0xFFFF701F) : Colors.transparent, width: 2))),
                        child: Text(sort == 1 ? '最新' : '最热', style: TextStyle(
                          color: _sort == sort ? Colors.black : Colors.grey,
                          fontSize: UiSizeUtil.homePageTitleFontSize)),
                      )),
                  ]));
                }
                if (index < _topics.length + 2) {
                  final topic = _topics[index - 2];
                  return HomeTopicCard(topic: topic,
                    onOpen: () => RouteUtils.push(context, WebViewPage(topicId: '${topic.topicId}')),
                    onLike: () => _like(topic), onFollow: () => _follow(topic),
                    onOpenTheme: (id, name) {
                      if (id == widget.themeId) return;
                      RouteUtils.push(context, ThemeDetailPage(themeId: id, name: name));
                    },
                  );
                }
                return Padding(padding: const EdgeInsets.all(16), child: Center(
                  child: _loading ? const CircularProgressIndicator()
                    : _listError != null
                      ? TextButton(onPressed: () => _loadTopics(), child: Text(_listError!))
                      : _hasMore
                        ? TextButton(onPressed: () => _loadTopics(), child: const Text('加载更多'))
                        : Text(_topics.isEmpty ? '暂无相关帖子' : '没有更多帖子了', style: const TextStyle(color: Colors.grey)),
                ));
              },
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
                heroTag: null,
                tooltip: '返回顶部',
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
      )),
    );
  }
}
