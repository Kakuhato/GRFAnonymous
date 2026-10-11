import 'package:flutter/material.dart';
import 'package:grfanonymous/pageRequest/requestUtils.dart';

class HomeFeedFilters extends StatelessWidget {
  const HomeFeedFilters({super.key, required this.official,
    required this.sort, required this.subId, required this.onSort,
    required this.onSubSelected});

  final bool official;
  final SortType sort;
  final int subId;
  final ValueChanged<SortType> onSort;
  final ValueChanged<int> onSubSelected;
  static const _subcategories = {1: '活动', 2: '新闻', 3: '公告'};

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(8))),
      child: official
          ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                for (final entry in _subcategories.entries)
                  InkWell(
                    onTap: () => onSubSelected(entry.key),
                    child: Container(
                      margin: const EdgeInsets.only(right: 20),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(border: Border(bottom: BorderSide(
                        color: subId == entry.key ? const Color(0xFFFF701F) : Colors.transparent,
                        width: 2,
                      ))),
                      child: Text(entry.value, style: TextStyle(fontSize: 18,
                          color: subId == entry.key ? Colors.black : Colors.grey)),
                    ),
                  ),
              ]),
            )
          : Row(children: [
              const Expanded(child: Text('筛选条件', style: TextStyle(color: Colors.grey))),
              DropdownButton<SortType>(
                value: sort,
                underline: const SizedBox.shrink(),
                items: SortType.values.map((value) => DropdownMenuItem(
                    value: value, child: Text(value.description))).toList(),
                onChanged: (value) { if (value != null) onSort(value); },
              ),
            ]),
    );
  }
}
