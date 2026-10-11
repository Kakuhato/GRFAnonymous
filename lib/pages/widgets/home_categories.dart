import 'package:flutter/material.dart';
import 'package:grfanonymous/pageRequest/requestUtils.dart';

class HomeCategories extends StatefulWidget {
  const HomeCategories({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final CategoryId selected;
  final ValueChanged<CategoryId> onSelected;

  // 显示顺序由产品定义，与接口 ID 的大小无关。
  static const categories = [
    CategoryId.recommend,
    CategoryId.restroom,
    CategoryId.strategy,
    CategoryId.fanArt,
    CategoryId.worldview,
    CategoryId.official,
    CategoryId.help,
  ];

  @override
  State<HomeCategories> createState() => _HomeCategoriesState();
}

class _HomeCategoriesState extends State<HomeCategories> {
  final _scrollController = ScrollController();
  final _viewportKey = GlobalKey();
  final _itemKeys = {
    for (final category in HomeCategories.categories) category: GlobalKey(),
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scheduleCenter();
  }

  @override
  void didUpdateWidget(covariant HomeCategories oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) _scheduleCenter();
  }

  void _scheduleCenter() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final item = _itemKeys[widget.selected]?.currentContext?.findRenderObject();
      final viewport = _viewportKey.currentContext?.findRenderObject();
      if (item is! RenderBox || viewport is! RenderBox) return;
      final center = item.localToGlobal(
        Offset(item.size.width / 2, 0), ancestor: viewport,
      ).dx;
      final position = _scrollController.position;
      final target = (position.pixels + center - viewport.size.width / 2)
          .clamp(position.minScrollExtent, position.maxScrollExtent)
          .toDouble();
      if ((target - position.pixels).abs() < 1) return;
      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      key: _viewportKey,
      color: Colors.white,
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: HomeCategories.categories.map((category) {
            final active = widget.selected == category;
            return InkWell(
              onTap: () {
                widget.onSelected(category);
                if (category == widget.selected) _scheduleCenter();
              },
              child: Container(
                key: _itemKeys[category],
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 2),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(
                    color: active ? const Color(0xFFFF701F) : Colors.transparent,
                    width: 2,
                  )),
                ),
                child: Text(category.description, style: TextStyle(
                  color: active ? const Color(0xFFFF701F) : Colors.black54,
                  fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 14,
                )),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
