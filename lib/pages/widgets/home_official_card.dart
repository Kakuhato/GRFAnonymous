import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:grfanonymous/models/topicList.dart';

class HomeOfficialCard extends StatelessWidget {
  const HomeOfficialCard({super.key, required this.topic,
    required this.isActivity, required this.onOpen});

  final Topic topic;
  final bool isActivity;
  final VoidCallback onOpen;

  String _date(String value) => value.split(' ').first;

  // 接口时间为中国标准时间，避免设备处于其他时区时状态偏移。
  DateTime? _time(String value) => value.isEmpty ? null
      : DateTime.tryParse('${value.replaceFirst(' ', 'T')}+08:00');

  @override
  Widget build(BuildContext context) {
    final begin = _time(topic.beginTime);
    final end = _time(topic.endTime);
    final now = DateTime.now().toUtc();
    final status = begin == null || end == null ? null
        : now.isBefore(begin) ? '未开始' : now.isAfter(end) ? '已结束' : '进行中';
    final cover = topic.coverPic.isNotEmpty ? topic.coverPic
        : topic.picList.isNotEmpty ? topic.picList.first : '';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: onOpen,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: const BoxDecoration(border: Border(
                bottom: BorderSide(color: Color(0xFFDDDDDD), width: 0.5))),
            child: LayoutBuilder(builder: (context, constraints) {
              return Row(children: [
                if (cover.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: CachedNetworkImage(
                      imageUrl: cover,
                      width: constraints.maxWidth * 0.32,
                      height: constraints.maxWidth * 0.18,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const ColoredBox(color: Color(0xFFF0F0F0)),
                      errorWidget: (_, __, ___) => const Icon(Icons.broken_image_outlined),
                    ),
                  ),
                  const SizedBox(width: 14),
                ],
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(topic.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 5),
                    if (isActivity)
                      Wrap(spacing: 4, runSpacing: 3, children: [
                        if (status != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: status == '进行中' ? const Color(0xFFFF9C32) : Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Text(status, style: const TextStyle(color: Colors.white, fontSize: 12)),
                          ),
                        if (topic.beginTime.isNotEmpty || topic.endTime.isNotEmpty)
                          Text('${_date(topic.beginTime)} - ${_date(topic.endTime)}',
                              style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ])
                    else
                      Text(_date(topic.createTime),
                          style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                )),
              ]);
            }),
          ),
        ),
      ),
    );
  }
}
