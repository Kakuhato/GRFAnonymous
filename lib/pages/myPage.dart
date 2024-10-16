import 'package:cached_network_image/cached_network_image.dart';
import 'package:demo/pageRequest/loginRequest.dart';
import 'package:demo/pageRequest/myPageRequest.dart';
import 'package:demo/pages/loginPage.dart';
import 'package:demo/ui/bottomSheet.dart';
import 'package:demo/utils/routeUtil.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  MyPageRequest myPageRequest = MyPageRequest();
  bool _isLoading = true;
  @override
  void initState() {
    _refresh();
    super.initState();
  }

  Future<void> _refresh() async {
    await myPageRequest.getUserData();
    await myPageRequest.getGameData();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                BottomSheetBuilder.showBottomSheet(
                  context,
                  backgroundColor: Colors.black,
                  (_) => Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: ListTile(
                          // leading: const Icon(Icons.settings),
                          title: const Text(
                            "退出登录",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          ),
                          onTap: () {
                            RouteUtils.pushAndRemove(
                                context, const LoginPage());
                            LoginRequest.exit();
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(
                Icons.settings_outlined,
                color: Colors.white,
                size: 40,
              ))
        ],
        title: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(left: 55),
            child: const Text(
              "我  的",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            )),
        backgroundColor: Colors.black,
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
                              width: 70,
                              height: 70,
                            ),
                          )),
                    ],
                  ),
                  _myCard(),
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
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
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
                style: const TextStyle(color: Colors.grey),
              ),
              const Spacer(),
              Text(
                "社区ID：${myPageRequest.userData.uid}",
                style: const TextStyle(color: Colors.grey),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: const BoxDecoration(
        color: Color.fromRGBO(242, 242, 242, 1),
      ),
      child: Row(
        children: [
          Row(
            children: [
              Text(
                myPageRequest.userData.fans.toString(),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 25,
                ),
              ),
              const Text(
                "粉丝",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Text(
                myPageRequest.userData.follows.toString(),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 25,
                ),
              ),
              const Text(
                "关注",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Text(
                myPageRequest.userData.likes.toString(),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 25,
                ),
              ),
              const Text(
                "获赞",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Text(
                myPageRequest.userData.favors.toString(),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 25,
                ),
              ),
              const Text(
                "收藏",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _myCard() {
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        Container(
          constraints: const BoxConstraints(
            maxHeight: 200,
            minHeight: 200,
          ),
          margin: const EdgeInsets.symmetric(horizontal: 15)
              .add(const EdgeInsets.only(top: 20)),
          child: CachedNetworkImage(
              imageUrl:
                  "https://gf2-cn.cdn.sunborngame.com/website/official/source/bbsm1727171280566/img/data_bg.e722b1ec.png",
              fit: BoxFit.cover),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 15)
              .add(const EdgeInsets.only(top: 55)),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: CachedNetworkImage(
                      imageUrl: myPageRequest.gameData.userInfo.avatar,
                      width: 60,
                      height: 60,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        myPageRequest.gameData.userInfo.nickName,
                        style: const TextStyle(
                          color: Color.fromRGBO(181, 143, 97, 1),
                          fontSize: 22,
                          // fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${myPageRequest.gameData.userInfo.level}级",
                        style: const TextStyle(
                          color: Color.fromRGBO(181, 143, 97, 1),
                          fontSize: 22,
                          // fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                ],
              ),
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10)
                        .add(const EdgeInsets.only(top: 15)),
                    child: Column(
                      children: [
                        Text(
                          myPageRequest.gameData.baseInfo.mainStage,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                          ),
                        ),
                        const Text(
                          "主线进度",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10)
                        .add(const EdgeInsets.only(top: 15)),
                    child: Column(
                      children: [
                        Text(
                          myPageRequest.gameData.baseInfo.heroCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                          ),
                        ),
                        const Text(
                          "人形收集",
                          style: TextStyle(color: Colors.white, fontSize: 22),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10)
                        .add(const EdgeInsets.only(top: 15)),
                    child: Column(
                      children: [
                        Text(
                          myPageRequest.gameData.baseInfo.achievementCount
                              .toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                          ),
                        ),
                        const Text(
                          "里程碑",
                          style: TextStyle(color: Colors.white, fontSize: 22),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}
