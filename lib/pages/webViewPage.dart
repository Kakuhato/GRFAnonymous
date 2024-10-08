import 'package:flutter/material.dart';

class WebViewPage extends StatefulWidget {
  final String title;
  const WebViewPage({super.key, required this.title});

  @override
  State<StatefulWidget> createState() {
    return _WebViewPageState();
  }
}

class _WebViewPageState extends State<WebViewPage> {
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
      body: SafeArea(child: Container()),
    );
  }
}

