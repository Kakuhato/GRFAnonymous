import 'package:flutter/cupertino.dart';

class MessagePage extends StatefulWidget {
  @override
  State createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text('消息'),
      ),
    );
  }
}
