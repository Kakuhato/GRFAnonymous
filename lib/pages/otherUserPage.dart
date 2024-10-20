import 'package:cached_network_image/cached_network_image.dart';
import 'package:grfanonymous/pageRequest/loginRequest.dart';
import 'package:grfanonymous/pageRequest/myPageRequest.dart';
import 'package:grfanonymous/pages/loginPage.dart';
import 'package:grfanonymous/ui/bottomSheet.dart';
import 'package:grfanonymous/utils/routeUtil.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';

import '../ui/uiSizeUtil.dart';

class OtherUserPage extends StatefulWidget {
  final String uid;
  const OtherUserPage({super.key, required this.uid});

  @override
  State createState() => _OtherUserPageState();
}

class _OtherUserPageState extends State<OtherUserPage> {
  MyPageRequest myPageRequest = MyPageRequest();
  bool _isLoading = true;
  @override
  void initState() {
    _refresh();
    super.initState();
  }

  Future<void> _refresh() async {
    await myPageRequest.getOtherUserData(widget.uid);
    await myPageRequest.getOtherGameData(widget.uid);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(UiSizeUtil.headerHeight),
        child: AppBar(
          // actions: [
          //   IconButton(
          //     onPressed: () {
          //       BottomSheetBuilder.showBottomSheet(
          //         context,
          //         backgroundColor: Colors.black,
          //         (_) => Column(
          //           children: [
          //             const SizedBox(
          //               height: 20,
          //             ),
          //             Container(
          //               margin: const EdgeInsets.symmetric(horizontal: 20),
          //               decoration: const BoxDecoration(
          //                 color: Colors.red,
          //                 borderRadius: BorderRadius.all(Radius.circular(10)),
          //               ),
          //               child: ListTile(
          //                 // leading: const Icon(Icons.settings),
          //                 title: const Text(
          //                   "退出登录",
          //                   textAlign: TextAlign.center,
          //                   style: TextStyle(color: Colors.white),
          //                 ),
          //                 onTap: () {
          //                   RouteUtils.pushAndRemove(
          //                       context, const LoginPage());
          //                   LoginRequest.exit();
          //                 },
          //               ),
          //             ),
          //           ],
          //         ),
          //       );
          //     },
          //     icon: Icon(
          //       Icons.settings_outlined,
          //       color: Colors.white,
          //       size: UiSizeUtil.topIconSize,
          //     ),
          //   )
          // ],
          // title: Container(
          //   alignment: Alignment.center,
          //   padding: const EdgeInsets.only(left: 45),
          //   child: Text(
          //     "我  的",
          //     style: TextStyle(
          //       color: Colors.white,
          //       fontWeight: FontWeight.bold,
          //       fontSize: UiSizeUtil.headerFontSize,
          //     ),
          //   ),
          // ),
          backgroundColor: Colors.black,
          automaticallyImplyLeading: true,
          iconTheme: IconThemeData(
            color: Colors.white,
            size: UiSizeUtil.topIconSize,
          ),
        ),
      ),
      backgroundColor: const Color.fromRGBO(245, 245, 245, 1),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : EasyRefresh(
              triggerAxis: Axis.vertical,
              header: const MaterialHeader(),
              footer: const CupertinoFooter(),
              child: ListView(
                children: [
                  Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        constraints: const BoxConstraints(
                          // maxWidth: 500,
                          maxHeight: 200,
                          minHeight: 200,
                        ),
                        child: CachedNetworkImage(
                          imageUrl:
                              "https://gf2-cn.cdn.sunborngame.com/website/official/source/bbsm1727171280566/img/mine_bg.91cacca5.png",
                          fit: BoxFit.cover,
                        ),
                      ),
                      _profileBuilder(),
                      Positioned(
                          top: 120,
                          left: 40,
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: myPageRequest.userData.avatar,
                              fit: BoxFit.cover,
                              width: UiSizeUtil.userAvatarSize,
                              height: UiSizeUtil.userAvatarSize,
                            ),
                          )),
                    ],
                  ),
                  _gameInfo(),
                ],
              ),
            ),
    );
  }

  Widget _profileBuilder() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20)
          .add(const EdgeInsets.only(top: 160)),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        children: [
          //用户名 个人资料
          Row(
            children: [
              Text(
                myPageRequest.userData.nickName,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: UiSizeUtil.userUserNameFontSize,
                ),
              ),
              const Spacer(),
              // Container(
              //   padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
              //   decoration: BoxDecoration(
              //       borderRadius: BorderRadius.circular(30),
              //       border: Border.all(
              //           color: Color.fromRGBO(246, 153, 97, 1), width: 2)),
              //   child: const Text(
              //     "修改个人资料",
              //     style: TextStyle(color: Color.fromRGBO(246, 153, 97, 1)),
              //   ),
              // ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          //ip属地，社区id
          Row(
            children: [
              Text(
                "ip属地：${myPageRequest.userData.ipLocation}",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: UiSizeUtil.userIdFontSize,
                ),
              ),
              const Spacer(),
              Text(
                "社区ID：${myPageRequest.userData.uid}",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: UiSizeUtil.userIdFontSize,
                ),
              ),
            ],
          ),
          _fansAndFollow(),
        ],
      ),
    );
  }

  Widget _fansAndFollow() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
      decoration: const BoxDecoration(
        color: Color.fromRGBO(242, 242, 242, 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            children: [
              Text(
                myPageRequest.userData.fans.toString(),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: UiSizeUtil.userFansNumFontSize,
                ),
              ),
              Text(
                "粉丝",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: UiSizeUtil.userFansFontSize,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                myPageRequest.userData.follows.toString(),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: UiSizeUtil.userFansNumFontSize,
                ),
              ),
              Text(
                "关注",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: UiSizeUtil.userFansFontSize,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                myPageRequest.userData.likes.toString(),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: UiSizeUtil.userFansNumFontSize,
                ),
              ),
              Text(
                "获赞",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: UiSizeUtil.userFansFontSize,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                myPageRequest.userData.favors.toString(),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: UiSizeUtil.userFansNumFontSize,
                ),
              ),
              Text(
                "收藏",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: UiSizeUtil.userFansFontSize,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _gameInfo() {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 200,
        minWidth: 200,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Center(
        child: Stack(
          children: [
            // 背景图片
            Container(
              constraints: const BoxConstraints(
                maxWidth: 350,
                // minWidth: 200,
              ),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: CachedNetworkImageProvider(
                      "https://gf2-cn.cdn.sunborngame.com/website/official/source/bbsm1727171280566/img/data_bg.e722b1ec.png"), // 动态背景图片
                  fit: BoxFit.fitWidth,
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(
                    height: 45,
                  ),
                  Container(
                    // margin: const EdgeInsets.symmetric(vertical: 20),
                    padding: const EdgeInsets.only(bottom: 20, left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // 头像
                            CachedNetworkImage(
                              imageUrl: myPageRequest
                                      .gameData.userInfo.avatar.isNotEmpty
                                  ? myPageRequest.gameData.userInfo.avatar
                                  : myPageRequest.userData.avatar, // 动态头像图片
                              height: 40,
                              width: 40,
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(width: 12),
                            // 用户名和等级
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  myPageRequest
                                      .gameData.userInfo.nickName, // 用户名
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize:
                                        UiSizeUtil.gameInfoCardUserNameFontSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "${myPageRequest.gameData.userInfo.level}级", // 等级
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize:
                                        UiSizeUtil.gameInfoCardLevelFontSize,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // 主线进度、收集数和里程碑
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildInfoText(
                                myPageRequest.gameData.baseInfo.mainStage,
                                "主线进度"),
                            _buildInfoText(
                                myPageRequest.gameData.baseInfo.heroCount
                                    .toString(),
                                "人形收集"),
                            _buildInfoText(
                                myPageRequest.gameData.baseInfo.achievementCount
                                    .toString(),
                                "里程碑"),
                            SizedBox(
                              width: 80,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoText(String value, String label) {
    return Column(
      children: [
        Text(
          value == "-1" ? "-" : value,
          style: TextStyle(
            color: Colors.white,
            fontSize: UiSizeUtil.gameInfoCardUserNameFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: UiSizeUtil.gameInfoCardLevelFontSize,
          ),
        ),
      ],
    );
  }
}
