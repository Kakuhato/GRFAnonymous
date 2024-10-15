import 'package:cached_network_image/cached_network_image.dart';
import 'package:demo/pageRequest/webViewRequest.dart';
import 'package:demo/utils/cacheUtil.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:oktoast/oktoast.dart';

class WebViewPage extends StatefulWidget {
  final String topicId;
  const WebViewPage({super.key, required this.topicId});

  @override
  State<StatefulWidget> createState() {
    return _WebViewPageState();
  }
}

class _WebViewPageState extends State<WebViewPage> {
  WebViewRequest webViewRequest = WebViewRequest();
  bool isLoading = true;

  @override
  void initState() {
    initTopic();
    super.initState();
  }

  Future initTopic() async {
    await webViewRequest.getWebViewContent(widget.topicId);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(245, 245, 245, 1),
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(
              Icons.star,
              size: 35,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              Icons.segment,
              size: 35,
            ),
            onPressed: () {},
          )
        ],
        backgroundColor: Colors.black,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.white, size: 35),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) => [
                        SliverToBoxAdapter(
                          child: _titleBuilder(),
                        ),
                        SliverToBoxAdapter(
                          child: _contentBuilder(),
                        ),
                      ],
              body: Container()
              // EasyRefresh(
              //   triggerAxis: Axis.vertical,
              //   header: const MaterialHeader(),
              //   refreshOnStart: true,
              //   onLoad: () async {},
              //   child: Container(
              //     child: Text("data"),
              //   ),
              // ),
              ),
    );
  }

  Widget _titleBuilder() {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipOval(
                  child: CachedNetworkImage(
                imageUrl: webViewRequest.webViewContent.userAvatar,
                width: 60,
                height: 60,
              )),
              Container(
                margin: const EdgeInsets.only(left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          webViewRequest.webViewContent.userNickName,
                          style: const TextStyle(
                            fontSize: 30,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: const Color.fromRGBO(248, 181, 141, 1),
                          ),
                          padding: const EdgeInsets.all(5),
                          margin: const EdgeInsets.only(left: 10),
                          child: Text(
                            "lv.${webViewRequest.webViewContent.userLevel}",
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color.fromRGBO(242, 108, 86, 1),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "${webViewRequest.webViewContent.viewNum}阅读  ${webViewRequest.webViewContent.ipLocation}",
                      style: const TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 10),
            child: Text(
              webViewRequest.webViewContent.title,
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 10),
            child: Text(
              "发布于 ${webViewRequest.webViewContent.createTime}",
              style: const TextStyle(
                fontSize: 15,
                color: Color.fromRGBO(153, 153, 153, 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contentBuilder() {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(horizontal: 10).add(
        const EdgeInsets.only(bottom: 10),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: HtmlWidget(
        webViewRequest.webViewContent.content,
        factoryBuilder: () => MyWidgetFactory(),
        customStylesBuilder: (element) {
          if (element.localName == 'p') {
            return {
              'margin': '5px 0',
            };
          }

          final style = element.attributes['style'];
          if (style != null) {
            final styles = style.split(';');
            Map<String, String> styleMap = {};
            for (var s in styles) {
              final keyValue = s.split(':');
              if (keyValue.length == 2) {
                styleMap[keyValue[0].trim()] = keyValue[1].trim();
              }
            }

            // 如果背景颜色是黑色，则将文字颜色设置为白色
            if (styleMap.containsKey('background-color')) {
              String backgroundColor = styleMap['background-color']!;
              if (backgroundColor.contains('rgb(0, 0, 0)') ||
                  backgroundColor == '#000000' ||
                  backgroundColor == 'black') {
                return {
                  'text-decoration': 'line-through',
                  'color': 'white', // 黑色背景时，文字颜色设置为白色
                };
              }
            }

            return {
              if (styleMap.containsKey('font-size'))
                'font-size': styleMap['font-size'] ?? '14px',
              if (styleMap.containsKey('color'))
                'color': styleMap['color'] ?? 'black',
            };
          }
          return null;
        },
        textStyle: const TextStyle(
          fontSize: 20,
          color: Colors.black,
        ),
      ),
    );
  }
}
