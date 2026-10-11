import 'package:flutter/material.dart';
import 'package:grfanonymous/models/top_topic.dart';

class HomeAnnouncements extends StatelessWidget {
  const HomeAnnouncements({super.key, required this.items, required this.onOpen});

  final List<TopTopic> items;
  final ValueChanged<int> onOpen;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        clipBehavior: Clip.antiAlias,
        child: Column(children: [
          for (final item in items)
            InkWell(
              onTap: () => onOpen(item.topicId),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFFF701F)),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(item.label, style: const TextStyle(
                        color: Color(0xFFFF701F), fontSize: 12)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(item.title, maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
                  const Icon(Icons.chevron_right, color: Colors.grey, size: 22),
                ]),
              ),
            ),
        ]),
      ),
    );
  }
}
