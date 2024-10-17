import 'package:flutter/material.dart';

class NavigationBarWidget extends StatefulWidget {
  NavigationBarWidget({
    super.key,
    required this.pages,
    required this.titles,
    required this.icons,
    required this.activeIcons,
    this.onTabChanged,
  }) {
    assert(pages.length == titles.length);
    assert(pages.length == icons.length);
    assert(pages.length == activeIcons.length);
  }

  final List<Widget> pages;
  final List<String> titles;
  final List<Widget> icons;
  final List<Widget> activeIcons;
  final ValueChanged<int>? onTabChanged;

  @override
  State createState() => _NavigationBarWidgetState();
}

class _NavigationBarWidgetState extends State<NavigationBarWidget> {
  int _currentIndex = 0;
  double _fontSize = 15;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {
        //     print('点击了浮动按钮');
        //   },
        // ),
        body: IndexedStack(
          index: _currentIndex,
          children: widget.pages,
        ),
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: TextStyle(
              // color: Color.fromRGBO(242, 108, 28, 1),
              fontSize: _fontSize,
              // fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: _fontSize,
              // fontWeight: FontWeight.bold,
            ),
            selectedItemColor: const Color.fromRGBO(242, 108, 28, 1),
            currentIndex: _currentIndex ?? 0,
            items: _barItemList(),
            onTap: (index) {
              _currentIndex = index;
              widget.onTabChanged?.call(index);
              setState(() {});
            },
          ),
        ));
  }

  List<BottomNavigationBarItem> _barItemList() {
    List<BottomNavigationBarItem> items = [];

    for (int i = 0; i < widget.pages.length; i++) {
      items.add(BottomNavigationBarItem(
        icon: widget.icons[i],
        activeIcon: widget.activeIcons[i],
        label: widget.titles[i],
      ));
    }
    return items;
  }
}
