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

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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

  _notificationListInit() async {
    await replyNotificationRequest.getReplyNotification(true);
    await likeNotificationRequest.getLikeNotification(true);
    await followNotificationRequest.getFollowNotification(true);
    await infoNotificationRequest.getInfoNotification(true);
    setState(() {});
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

  Widget _buildRplyTab() {
    return EasyRefresh(
      header: const MaterialHeader(),
      // footer: const MaterialFooter(),
      onRefresh: () async {
        _notificationListInit(); //刷新
        setState(() {});
      },
      onLoad: replyNotificationRequest.replyList.length !=
              replyNotificationRequest.total
          ? () async {
              await replyNotificationRequest.getReplyNotification(false);
              setState(() {});
            }
          : null,
      child: SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: replyNotificationRequest.replyList.length,
              itemBuilder: (context, index) {
                return _replyTab(replyNotificationRequest.replyList[index]);
              },
            ),
            if (replyNotificationRequest.replyList.length ==
                replyNotificationRequest.total)
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

  Widget _buildLikesTab() {
    return EasyRefresh(
      header: const MaterialHeader(),
      // footer: const MaterialFooter(),
      onRefresh: () async {
        _notificationListInit();
        setState(() {});
      },
      onLoad: likeNotificationRequest.likeList.length !=
              likeNotificationRequest.total
          ? () async {
              await likeNotificationRequest.getLikeNotification(false);
              setState(() {});
            }
          : null,
      child: SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: likeNotificationRequest.likeList.length,
              itemBuilder: (context, index) {
                return _likeTab(likeNotificationRequest.likeList[index]);
              },
            ),
            if (likeNotificationRequest.likeList.length ==
                likeNotificationRequest.total)
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
    return EasyRefresh(
      header: const MaterialHeader(),
      // footer: const MaterialFooter(),
      onRefresh: () async {
        _notificationListInit();
        setState(() {});
      },
      onLoad: followNotificationRequest.followList.length !=
              followNotificationRequest.total
          ? () async {
              await followNotificationRequest.getFollowNotification(false);
              setState(() {});
            }
          : null,
      child: SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: followNotificationRequest.followList.length,
              itemBuilder: (context, index) {
                return _followTab(followNotificationRequest.followList[index]);
              },
            ),
            if (followNotificationRequest.followList.length ==
                followNotificationRequest.total)
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
    return EasyRefresh(
      header: const MaterialHeader(),
      // footer: const MaterialFooter(),
      onRefresh: () async {
        _notificationListInit();
        setState(() {});
      },
      onLoad: infoNotificationRequest.infoList.length !=
              infoNotificationRequest.total
          ? () async {
              await infoNotificationRequest.getInfoNotification(false);
              setState(() {});
            }
          : null,
      child: SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: infoNotificationRequest.infoList.length,
              itemBuilder: (context, index) {
                return _infoTab(infoNotificationRequest.infoList[index]);
              },
            ),
            if (infoNotificationRequest.infoList.length ==
                infoNotificationRequest.total)
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
