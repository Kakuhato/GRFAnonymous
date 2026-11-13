import '../utils/image_decode_size.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grfanonymous/models/notifications/InfoList.dart';
import 'package:grfanonymous/models/notifications/followList.dart';
import 'package:grfanonymous/models/notifications/likeList.dart';
import 'package:grfanonymous/models/notifications/replyList.dart';
import 'package:grfanonymous/pageRequest/notificationPageRequest/infoNotificationRequest.dart';
import 'package:grfanonymous/pageRequest/notificationPageRequest/likeNotificationRequest.dart';
import 'package:grfanonymous/pages/otherUserPage.dart';
import 'package:grfanonymous/pages/webViewPage.dart';
import 'package:oktoast/oktoast.dart';

import '../pageRequest/notificationPageRequest/followNotificationRequest.dart';
import '../pageRequest/notificationPageRequest/replyNotificationRequest.dart';
import '../ui/uiSizeUtil.dart';
import '../utils/routeUtil.dart';
import 'widgets/comment_thread_sheet.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _replySheetOpen = false;
  Future<IndicatorResult>? _refreshFuture;

  ReplyNotificationRequest replyNotificationRequest =
      ReplyNotificationRequest();
  LikeNotificationRequest likeNotificationRequest = LikeNotificationRequest();
  FollowNotificationRequest followNotificationRequest =
      FollowNotificationRequest();
  InfoNotificationRequest infoNotificationRequest = InfoNotificationRequest();

  @override
  void initState() {
    super.initState();
    _notificationListInit();
    _tabController = TabController(length: 4, vsync: this);
  }

  Future<IndicatorResult> _notificationListInit() {
    return _refreshFuture ??= _refreshNotifications();
  }

  Future<IndicatorResult> _refreshNotifications() async {
    try {
      await replyNotificationRequest.getReplyNotification(true);
      await likeNotificationRequest.getLikeNotification(true);
      await followNotificationRequest.getFollowNotification(true);
      await infoNotificationRequest.getInfoNotification(true);
      return IndicatorResult.success;
    } catch (_) {
      if (mounted) showToast('消息刷新失败，请稍后重试');
      return IndicatorResult.fail;
    } finally {
      _refreshFuture = null;
      if (mounted) setState(() {});
    }
  }

  _clearAll() {
    for (var item in replyNotificationRequest.replyList) {
      item.isRead = true;
    }
    for (var item in likeNotificationRequest.likeList) {
      item.isRead = true;
    }
    for (var item in followNotificationRequest.followList) {
      item.isRead = true;
    }
    for (var item in infoNotificationRequest.infoList) {
      item.isRead = true;
    }
    replyNotificationRequest.unread = 0;
    likeNotificationRequest.unread = 0;
    followNotificationRequest.unread = 0;
    infoNotificationRequest.unread = 0;
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 回复弹层自行避让键盘，消息列表不跟随键盘重新布局。
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(UiSizeUtil.headerHeight),
        child: AppBar(
          actions: [
            IconButton(
                onPressed: () async {
                  await replyNotificationRequest.readAll();
                  _clearAll();
                  setState(() {});
                },
                icon: Icon(
                  Icons.cleaning_services_outlined,
                  color: Colors.white,
                  size: UiSizeUtil.topIconSize,
                ))
          ],
          title: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(left: 45),
              child: Text(
                "消  息",
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
      body: Column(
        children: [
          // TabBar 独立显示，非 AppBar 部分
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.orange,
              labelColor: Colors.orange,
              unselectedLabelColor: Colors.grey,
              tabs: [
                _buildTabWithBadge("回复", replyNotificationRequest.unread),
                _buildTabWithBadge("获赞", likeNotificationRequest.unread),
                _buildTabWithBadge("关注", followNotificationRequest.unread),
                _buildTabWithBadge("通知", infoNotificationRequest.unread),
              ],
            ),
          ),
          // TabBarView 用来显示对应的内容
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRplyTab(),
                _buildLikesTab(),
                _buildFollowingTab(),
                _buildInfoTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabWithBadge(String title, int unreadCount) {
    return Stack(
      clipBehavior: Clip.none, // 确保小红点可以超出Stack边界
      children: [
        Tab(text: title), // Tab 的标题文本
        if (unreadCount > 0) // 如果有未读消息，则显示小红点
          Positioned(
            right: -10, // 调整位置使其靠近Tab的右上角
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red, // 小红点的颜色
                shape: BoxShape.circle, // 圆形
              ),
              constraints: BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Center(
                child: Text(
                  unreadCount.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNotificationList({
    required String storageKey,
    required int itemCount,
    required int total,
    required IndexedWidgetBuilder itemBuilder,
    required Future<void> Function() onLoad,
  }) {
    final hasMore = itemCount < total;
    return EasyRefresh.builder(
      fit: StackFit.expand,
      header: const MaterialHeader(),
      onRefresh: _notificationListInit,
      onLoad: hasMore ? () async {
        try {
          // 其他标签也可能正在刷新，分页应等待刷新后的页码。
          final refreshing = _refreshFuture;
          if (refreshing != null && await refreshing != IndicatorResult.success) {
            return IndicatorResult.fail;
          }
          if (!mounted) return IndicatorResult.fail;
          await onLoad();
          return IndicatorResult.success;
        } catch (_) {
          if (mounted) showToast('消息加载失败，请稍后重试');
          return IndicatorResult.fail;
        } finally {
          if (mounted) setState(() {});
        }
      } : null,
      childBuilder: (context, physics) => ListView.builder(
        key: PageStorageKey('message_$storageKey'),
        padding: EdgeInsets.zero,
        // 保留刷新组件的回弹逻辑；其默认父级允许空列表和短列表拖动。
        physics: physics,
        itemCount: itemCount + (hasMore ? 0 : 1),
        itemBuilder: (context, index) {
          if (index < itemCount) return itemBuilder(context, index);
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text('没有更多了', textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, color: Color(0xFF969799))),
          );
        },
      ),
    );
  }

  Widget _buildRplyTab() {
    final items = List.of(replyNotificationRequest.replyList);
    return _buildNotificationList(
      storageKey: 'replies',
      itemCount: items.length,
      total: replyNotificationRequest.total,
      itemBuilder: (context, index) => _replyTab(items[index]),
      onLoad: () async { await replyNotificationRequest.getReplyNotification(false); },
    );
  }

  Future<void> _openReplyThread(ReplyItem item) async {
    if (_replySheetOpen) return;
    _replySheetOpen = true;
    try {
      await showCommentThreadSheet(
        context: context,
        topicId: item.topicId.toString(), commentId: item.commentId,
        showOriginalTopic: true,
        onOpenTopic: (context, topicId) => RouteUtils.push(
          context, WebViewPage(topicId: topicId)),
      );
    } finally {
      _replySheetOpen = false;
    }
  }

  Widget _replyTab(ReplyItem item) {
    return GestureDetector(
      child: Container(
        color: Colors.white,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 添加边框的容器
            Container(
              margin: const EdgeInsets.only(bottom: 15), // 设置内边距
              width: 10, // 设置宽度
              height: 10, // 设置高度
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: item.isRead ? Colors.white : Colors.red,
              ),
            ),
            const SizedBox(width: 10), // 添加间距
            Expanded(
              // 确保剩余空间被文本部分填充
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // 左对齐
                children: [
                  // 第一行内容：头像和标题
                  Row(
                    children: [
                      // 头像部分
                      ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: item.avatarUrl,
                          memCacheWidth: ImageDecodeSize.width(context, 40),
                          width: 40,
                          height: 40,
                        ),
                      ),
                      const SizedBox(width: 5), // 添加间距

                      // 文本部分
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              overflow: TextOverflow.ellipsis, // 超出一行时省略号
                              maxLines: 1, // 限制为一行
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              item.content,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // 第三行内容：时间显示
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        item.logTime,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      onTap: () => _openReplyThread(item),
    );
  }

  Widget _buildLikesTab() {
    final items = List.of(likeNotificationRequest.likeList);
    return _buildNotificationList(
      storageKey: 'likes',
      itemCount: items.length,
      total: likeNotificationRequest.total,
      itemBuilder: (context, index) => _likeTab(items[index]),
      onLoad: () async { await likeNotificationRequest.getLikeNotification(false); },
    );
  }

  Widget _likeTab(LikeItem item) {
    return GestureDetector(
      child: Container(
        color: Colors.white,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 添加边框的容器
            Container(
              margin: const EdgeInsets.only(bottom: 15), // 设置内边距
              width: 10, // 设置宽度
              height: 10, // 设置高度
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: item.isRead ? Colors.white : Colors.red,
              ),
            ),
            const SizedBox(width: 10), // 添加间距
            Expanded(
              // 确保剩余空间被文本部分填充
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // 左对齐
                children: [
                  // 第一行内容：头像和标题
                  Row(
                    children: [
                      // 头像部分
                      ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: item.avatarUrl,
                          memCacheWidth: ImageDecodeSize.width(context, 40),
                          width: 40,
                          height: 40,
                        ),
                      ),
                      const SizedBox(width: 5), // 添加间距

                      // 文本部分
                      Expanded(
                        child: Text(
                          item.title,
                          overflow: TextOverflow.ellipsis, // 超出一行时省略号
                          maxLines: 1, // 限制为一行
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // 第二行内容：时间显示
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        item.logTime,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        RouteUtils.push(
          context,
          WebViewPage(
            topicId: item.topicId.toString(),
          ),
        );
      },
    );
  }

  Widget _buildFollowingTab() {
    final items = List.of(followNotificationRequest.followList);
    return _buildNotificationList(
      storageKey: 'follows',
      itemCount: items.length,
      total: followNotificationRequest.total,
      itemBuilder: (context, index) => _followTab(items[index]),
      onLoad: () async { await followNotificationRequest.getFollowNotification(false); },
    );
  }

  Widget _followTab(FollowItem item) {
    return GestureDetector(
      child: Container(
        color: Colors.white,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 添加边框的容器
            Container(
              margin: const EdgeInsets.only(bottom: 15), // 设置内边距
              width: 10, // 设置宽度
              height: 10, // 设置高度
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: item.isRead ? Colors.white : Colors.red,
              ),
            ),
            const SizedBox(width: 10), // 添加间距
            Expanded(
              // 确保剩余空间被文本部分填充
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // 左对齐
                children: [
                  // 第一行内容：头像和标题
                  Row(
                    children: [
                      // 头像部分
                      ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: item.avatarUrl,
                          memCacheWidth: ImageDecodeSize.width(context, 40),
                          width: 40,
                          height: 40,
                        ),
                      ),
                      const SizedBox(width: 5), // 添加间距

                      // 文本部分
                      Expanded(
                        child: Text(
                          item.title,
                          overflow: TextOverflow.ellipsis, // 超出一行时省略号
                          maxLines: 1, // 限制为一行
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // 第二行内容：时间显示
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        item.logTime,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        // showToast(item.userId.toString());
        RouteUtils.push(
          context,
          OtherUserPage(uid: item.userId.toString()),
        );
      },
    );
  }

  Widget _buildInfoTab() {
    final items = List.of(infoNotificationRequest.infoList);
    return _buildNotificationList(
      storageKey: 'info',
      itemCount: items.length,
      total: infoNotificationRequest.total,
      itemBuilder: (context, index) => _infoTab(items[index]),
      onLoad: () async { await infoNotificationRequest.getInfoNotification(false); },
    );
  }

  Widget _infoTab(InfoItem item) {
    return GestureDetector(
      child: Container(
        color: Colors.white,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding:
            const EdgeInsets.all(10).add(const EdgeInsets.only(bottom: 15)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 添加边框的容器
            Container(
              margin: const EdgeInsets.only(bottom: 15), // 设置内边距
              width: 10, // 设置宽度
              height: 10, // 设置高度
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: item.isRead ? Colors.white : Colors.red,
              ),
            ),
            const SizedBox(width: 10), // 添加间距
            Expanded(
              // 确保剩余空间被文本部分填充
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // 左对齐
                children: [
                  // 第一行内容：头像和标题
                  Row(
                    children: [
                      // 头像部分
                      // ClipOval(
                      //   child: CachedNetworkImage(
                      //     imageUrl: item.avatarUrl,
                      //     width: 40,
                      //     height: 40,
                      //   ),
                      // ),
                      const SizedBox(width: 5), // 添加间距

                      // 文本部分
                      Expanded(
                        child: Text(
                          item.title,
                          overflow: TextOverflow.ellipsis, // 超出一行时省略号
                          maxLines: 1, // 限制为一行
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // 第二行内容：时间显示
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        item.logTime,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        showToast("暂未实现");
        // RouteUtils.push(
        //   context,
        //   WebViewPage(
        //     topicId: item.topicId.toString(),
        //   ),
        // );
      },
    );
  }
}
