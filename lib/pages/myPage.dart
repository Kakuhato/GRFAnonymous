import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {},
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
      body: EasyRefresh(
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
                  child: Image.network(
                    "https://gf2-cn.cdn.sunborngame.com/website/official/source/bbsm1727171280566/img/mine_bg.91cacca5.png",
                    fit: BoxFit.cover,
                  ),
                ),
                _profileBuilder(),
                Positioned(
                    top: 120,
                    left: 40,
                    child: ClipOval(
                      child: Image.network(
                        "https://community.cdn.sunborngame.com/prod/image/1714297290156.png",
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
              const Text(
                "西门芒果",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                        color: Color.fromRGBO(246, 153, 97, 1), width: 2)),
                child: const Text(
                  "个人资料",
                  style: TextStyle(color: Color.fromRGBO(246, 153, 97, 1)),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          //ip属地，社区id
          const Row(
            children: [
              Text(
                "ip属地：中国",
                style: TextStyle(color: Colors.grey),
              ),
              Spacer(),
              Text(
                "社区ID：123456",
                style: TextStyle(color: Colors.grey),
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
              const Text(
                "0",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
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
              const Text(
                "0",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
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
              const Text(
                "0",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
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
              const Text(
                "0",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
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
          child: Image.network(
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
                    child: Image.network(
                      "https://community.cdn.sunborngame.com/prod/image/1714297290156.png",
                      width: 60,
                      height: 60,
                    ),
                  ),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "西门芒果",
                        style: TextStyle(
                          color: Color.fromRGBO(181, 143, 97, 1),
                          fontSize: 22,
                          // fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "60级",
                        style: TextStyle(
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
                        const Text(
                          "8-10",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                          ),
                        ),
                        const Text(
                          "主线进度",
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
                        const Text(
                          "26",
                          style: TextStyle(
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
                        const Text(
                          "414",
                          style: TextStyle(
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
