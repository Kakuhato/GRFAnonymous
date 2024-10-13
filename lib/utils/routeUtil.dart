import 'package:demo/pages/homePage.dart';
import 'package:demo/pages/loginPage.dart';
import 'package:demo/pages/tabPage.dart';
import 'package:demo/pages/webViewPage.dart';
import 'package:flutter/material.dart';

class Routes {
  // static Route<dynamic> generateRoute(RouteSettings settings) {
  //   switch (settings.name) {
  //     case RoutePath.tab:
  //       return pageRoute(TabPage());
  //     case RoutePath.webViewPage:
  //       return pageRoute(const WebViewPage(title: "12"));
  //     case RoutePath.loginPage:
  //       return pageRoute(const LoginPage(),settings: settings);
  //   }
  //   return pageRoute(Scaffold(
  //     body: SafeArea(
  //         child: Center(
  //       child: Text("路由：${settings.name} 不存在 "),
  //     )),
  //   ));
  // }

  static MaterialPageRoute pageRoute(Widget page,
      {RouteSettings? settings,
      bool? fullscreenDialog,
      bool? maintainState,
      bool? allowSnapshotting}) {
    return MaterialPageRoute(
        builder: (context) {
          return page;
        },
        settings: settings,
        fullscreenDialog: fullscreenDialog ?? false,
        maintainState: fullscreenDialog ?? true,
        allowSnapshotting: allowSnapshotting ?? true);
  }
}

//路由地址
// class RoutePath {
//   static const String tab = "/";
//   static const String webViewPage = "/web_view_page";
//   static const String loginPage = "/login_page";
// }

class RouteUtils {
  RouteUtils._();

  static Future push(
    BuildContext context,
    Widget page, {
    bool? fullscreenDialog,
    RouteSettings? settings,
    bool maintainState = true,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => page,
        fullscreenDialog: fullscreenDialog ?? false,
        settings: settings,
        maintainState: maintainState,
      ),
    );
  }

  static pushAndRemove(BuildContext context, Widget page) {
    return Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => page),
      (route) => false,
    );
  }

}

