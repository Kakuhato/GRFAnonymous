import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/topicList.dart';
import '../models/search_user.dart';
import '../pageRequest/likeAndFollow.dart';
import '../pageRequest/search_request.dart';
import '../ui/uiSizeUtil.dart';
import '../utils/routeUtil.dart';
import '../utils/topic_link.dart';
import 'webViewPage.dart';
import 'otherUserPage.dart';
import 'widgets/home_topic_card.dart';
import 'widgets/search_user_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _request = SearchRequest();
  final _likeAndFollow = LikeAndFollow();
  final _liking = <int>{};
  final _topics = <Topic>[];
  final _users = <SearchUser>[];
  SearchType _searchType = SearchType.topics;
  CancelToken? _cancelToken;
  String _keyword = '';
  String? _error;
  String? _openedTopicId;
  int _requestId = 0;
  int _page = 0;
  int? _total;
  bool _loading = false;
  bool _hasMore = false;

  int get _resultCount => _searchType == SearchType.topics ? _topics.length : _users.length;

  void _selectType(SearchType type) {
    if (type == _searchType) return;
    _cancelToken?.cancel();
    ++_requestId;
    setState(() {
      _searchType = type;
      _keyword = _input.text.trim();
      _topics.clear();
      _users.clear();
      _page = 0;
      _total = null;
      _error = null;
      _openedTopicId = null;
      _loading = false;
      _hasMore = false;
    });
    if (_keyword.isNotEmpty) {
      FocusScope.of(context).unfocus();
      _fetch(reset: true, tryDirect: true);
    }
  }

  @override
  void dispose() {
    _cancelToken?.cancel();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _submit() {
    final keyword = _input.text.trim();
    if (keyword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入搜索内容')));
      return;
    }
    FocusScope.of(context).unfocus();
    _keyword = keyword;
    _fetch(reset: true, tryDirect: true);
  }

  Future<void> _fetch({bool reset = false, bool tryDirect = false}) async {
    if (_keyword.isEmpty || (!reset && (_loading || !_hasMore))) return;
    _cancelToken?.cancel();
    final token = CancelToken();
    _cancelToken = token;
    final requestId = ++_requestId;
    final nextPage = reset ? 1 : _page + 1;
    if (reset && _scroll.hasClients) _scroll.jumpTo(0);
    setState(() {
      _loading = true;
      _error = null;
      if (reset) {
        _openedTopicId = null;
        _topics.clear();
        _users.clear();
        _page = 0;
        _total = null;
        _hasMore = false;
      }
    });
    try {
      final topicId = tryDirect ? TopicLink.parseId(_keyword) : null;
      if (topicId != null) {
        final exists = await _request.topicExists(topicId, cancelToken: token);
        if (!mounted || requestId != _requestId || token.isCancelled) return;
        if (exists) {
          setState(() {
            _openedTopicId = topicId;
            _loading = false;
          });
          RouteUtils.push(context, WebViewPage(topicId: topicId));
          return;
        }
      }
      final result = await _request.search(
        content: _keyword, page: nextPage, searchType: _searchType, cancelToken: token,
      );
      if (!mounted || requestId != _requestId) return;
      setState(() {
        final ids = _topics.map((topic) => topic.topicId).toSet();
        _topics.addAll(result.topics.where((topic) => ids.add(topic.topicId)));
        final userIds = _users.map((user) => user.uid).toSet();
        _users.addAll(result.users.where((user) => userIds.add(user.uid)));
        _page = nextPage;
        _total = result.total;
        _hasMore = result.hasMore;
      });
    } catch (error) {
      if (!mounted || requestId != _requestId || token.isCancelled) return;
      setState(() => _error = error is TopicSearchException ? error.message : '搜索失败，请重试');
    } finally {
      if (mounted && requestId == _requestId) setState(() => _loading = false);
    }
  }

  Future<void> _like(Topic topic) async {
    if (!_liking.add(topic.topicId)) return;
    try {
      final success = await _likeAndFollow.like(topic.topicId.toString());
      if (!mounted) return;
      if (!success) throw StateError('点赞失败');
      setState(() {
        topic.isLike = !topic.isLike;
        topic.likeNum += topic.isLike ? 1 : -1;
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('点赞操作失败，请重试')));
      }
    } finally {
      _liking.remove(topic.topicId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('搜索', style: TextStyle(
          fontSize: UiSizeUtil.headerFontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        )),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _input,
                    autofocus: true,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      hintText: '搜索${_searchType.label}，或粘贴帖子链接 / ID',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        tooltip: '清空输入',
                        onPressed: _input.clear,
                        icon: const Icon(Icons.clear),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                TextButton(onPressed: _submit, child: const Text('搜索')),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                for (final type in SearchType.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(type.label),
                      selected: _searchType == type,
                      onSelected: (_) => _selectType(type),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(child: _results()),
        ],
      ),
    );
  }

  Widget _results() {
    if (_keyword.isEmpty) return Center(child: Text('输入关键词搜索${_searchType.label}'));
    if (_loading && _resultCount == 0) return const Center(child: CircularProgressIndicator());
    if (_error != null && _resultCount == 0) {
      return Center(child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_error!, textAlign: TextAlign.center),
          TextButton(onPressed: () => _fetch(reset: true, tryDirect: true), child: const Text('重试')),
        ],
      ));
    }
    if (_openedTopicId != null) {
      return Center(child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('已找到帖子 #$_openedTopicId'),
          TextButton(
            onPressed: () => RouteUtils.push(context, WebViewPage(topicId: _openedTopicId!)),
            child: const Text('打开帖子'),
          ),
        ],
      ));
    }
    return RefreshIndicator(
      onRefresh: () => _fetch(reset: true),
      child: ListView.builder(
        controller: _scroll,
        physics: const AlwaysScrollableScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.only(bottom: 24),
        itemCount: _resultCount + 2,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(_resultCount == 0 ? '没有找到相关${_searchType.label}' : '“$_keyword”${_total == null ? '' : ' 共 $_total 条结果'}'),
            );
          }
          if (index <= _resultCount) {
            if (_searchType == SearchType.users) {
              final user = _users[index - 1];
              return SearchUserCard(
                user: user,
                onOpen: () => RouteUtils.push(context, OtherUserPage(uid: user.uid.toString())),
              );
            }
            final topic = _topics[index - 1];
            return HomeTopicCard(
              topic: topic,
              showFollowButton: false,
              onOpen: () => RouteUtils.push(context, WebViewPage(topicId: topic.topicId.toString())),
              onLike: () => _like(topic),
            );
          }
          if (_loading) {
            return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()));
          }
          if (_error != null) {
            return Column(children: [
              Text(_error!, textAlign: TextAlign.center),
              TextButton(onPressed: () => _fetch(), child: const Text('重试加载')),
            ]);
          }
          if (_hasMore) return TextButton(onPressed: () => _fetch(), child: const Text('加载更多'));
          return const Padding(padding: EdgeInsets.all(16), child: Center(child: Text('没有更多了')));
        },
      ),
    );
  }
}
