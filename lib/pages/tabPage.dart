import 'package:demo/pages/followPage.dart';
import 'package:demo/pages/homePage.dart';
import 'package:demo/pages/messagePage.dart';
import 'package:demo/pages/myPage.dart';
import 'package:flutter/material.dart';
import 'package:demo/ui/navigationBar.dart';

class TabPage extends StatefulWidget {
  @override
  State createState() => _TabPageState();
}

class _TabPageState extends State<TabPage> {
  late List<Widget> pages;
  late List<String> titles;
  late List<Widget> icons;
  late List<Widget> activeIcons;

  void initTableData() {
    pages = [
      HomePage(),
      FollowPage(),
      MessagePage(),
      MyPage(),
    ];
    titles = [
      '主 页',
      '关 注',
      '消 息',
      '我 的',
    ];
    double iconSize = 35;
    icons = [
      Image.asset(
        "assets/barItem/homePageUnSelected.png",
        width: iconSize,
        height: iconSize,
      ),
      Image.asset(
        "assets/barItem/followUnSelected.png",
        width: iconSize,
        height: iconSize,
      ),
      Image.asset(
        "assets/barItem/messageUnSelected.png",
        width: iconSize,
        height: iconSize,
      ),
      Image.asset(
        "assets/barItem/myPageUnSelected.png",
        width: iconSize,
        height: iconSize,
      ),
    ];

    activeIcons = [
      Image.asset(
        "assets/barItem/homePageSelected.png",
        width: iconSize,
        height: iconSize,
      ),
      Image.asset(
        "assets/barItem/followSelected.png",
        width: iconSize,
        height: iconSize,
      ),
      Image.asset(
        "assets/barItem/messageSelected.png",
        width: iconSize,
        height: iconSize,
      ),
      Image.asset(
        "assets/barItem/myPageSelected.png",
        width: iconSize,
        height: iconSize,
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    initTableData();
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBarWidget(
      pages: pages,
      titles: titles,
      icons: icons,
      activeIcons: activeIcons,
    );
    // Scaffold(
    //     // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    //     // floatingActionButton: FloatingActionButton(
    //     //   onPressed: () {
    //     //     print('点击了浮动按钮');
    //     //   },
    //     // ),
    //     body: IndexedStack(
    //       index: _currentIndex,
    //       children: [
    //         HomePage(),
    //         FollowPage(),
    //         MessagePage(),
    //         MyPage(),
    //       ],
    //     ),
    //     bottomNavigationBar: Theme(
    //       data: Theme.of(context).copyWith(
    //         splashColor: Colors.transparent,
    //         highlightColor: Colors.transparent,
    //       ),
    //       child: BottomNavigationBar(
    //         backgroundColor: Colors.white,
    //         type: BottomNavigationBarType.fixed,
    //         selectedLabelStyle: TextStyle(
    //           // color: Color.fromRGBO(242, 108, 28, 1),
    //           fontSize: 20,
    //           fontWeight: FontWeight.bold,
    //         ),
    //         unselectedLabelStyle: TextStyle(
    //           fontSize: 20,
    //           fontWeight: FontWeight.bold,
    //         ),
    //         selectedItemColor: Color.fromRGBO(242, 108, 28, 1),
    //         currentIndex: _currentIndex,
    //         items: _barItemList(),
    //         onTap: (index) {
    //           _currentIndex = index;
    //           setState(() {});
    //         },
    //       ),
    //     ));
  }

  // List<BottomNavigationBarItem> _barItemList() {
  //   double iconSize = 35;
  //   List<BottomNavigationBarItem> items = [];
  //   items.add(BottomNavigationBarItem(
  //     activeIcon: Image.asset("assets/barItem/homePageSelected.png",
  //         width: iconSize, height: iconSize),
  //     icon: Image.asset("assets/barItem/homePageUnSelected.png",
  //         width: iconSize, height: iconSize),
  //     label: '主 页',
  //   ));
  //   items.add(BottomNavigationBarItem(
  //     activeIcon: Image.asset("assets/barItem/followSelected.png",
  //         width: iconSize, height: iconSize),
  //     icon: Image.asset("assets/barItem/followUnSelected.png",
  //         width: iconSize, height: iconSize),
  //     label: '关 注',
  //   ));
  //   items.add(BottomNavigationBarItem(
  //     activeIcon: Image.asset("assets/barItem/messageSelected.png",
  //         width: iconSize, height: iconSize),
  //     icon: Image.asset("assets/barItem/messageUnSelected.png",
  //         width: iconSize, height: iconSize),
  //     label: '消 息',
  //   ));
  //   items.add(BottomNavigationBarItem(
  //     activeIcon: Image.asset("assets/barItem/myPageSelected.png",
  //         width: iconSize, height: iconSize),
  //     icon: Image.asset("assets/barItem/myPageUnSelected.png",
  //         width: iconSize, height: iconSize),
  //     label: '我 的',
  //   ));
  //
  //   return items;
  // }
}
