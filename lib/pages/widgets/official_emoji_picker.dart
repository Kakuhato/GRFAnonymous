import 'package:cached_network_image/cached_network_image.dart';
import '../../utils/image_decode_size.dart';
import 'package:flutter/material.dart';

import '../../pageRequest/emoji_request.dart';

class OfficialEmojiPicker extends StatefulWidget {
  const OfficialEmojiPicker({super.key, required this.onCancel, required this.onSelected});

  final VoidCallback onCancel;
  final ValueChanged<OfficialEmoji> onSelected;

  @override
  State<OfficialEmojiPicker> createState() => _OfficialEmojiPickerState();
}

class _OfficialEmojiPickerState extends State<OfficialEmojiPicker> {
  List<EmojiCategory> _categories = [];
  int _selected = 0;
  bool _loading = true;
  bool _failed = false;
  bool _loadScheduled = false;
  Animation<double>? _openingAnimation;

  @override
  void initState() {
    super.initState();
    EmojiRequest.changes.addListener(_onCatalogChanged);
  }

  void _onCatalogChanged() {
    final categories = EmojiRequest.changes.value;
    if (!mounted || categories == null) return;
    final selectedId = _categories.isEmpty ? null : _categories[_selected].id;
    final nextIndex = categories.indexWhere((category) => category.id == selectedId);
    setState(() {
      _categories = categories;
      _selected = nextIndex < 0 ? 0 : nextIndex;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loadScheduled) return;
    _loadScheduled = true;
    final animation = ModalRoute.of(context)?.animation;
    if (animation == null || animation.status == AnimationStatus.completed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _load();
      });
    } else {
      _openingAnimation = animation;
      animation.addStatusListener(_onAnimationStatus);
    }
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    _openingAnimation?.removeStatusListener(_onAnimationStatus);
    _openingAnimation = null;
    if (mounted) _load();
  }

  @override
  void dispose() {
    EmojiRequest.changes.removeListener(_onCatalogChanged);
    _openingAnimation?.removeStatusListener(_onAnimationStatus);
    super.dispose();
  }

  Future<void> _load({bool refresh = false}) async {
    setState(() { _loading = true; _failed = false; });
    try {
      final categories = await EmojiRequest().load(refresh: refresh);
      if (!mounted) return;
      setState(() { _categories = categories; _selected = 0; });
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _image(String url, {double displayWidth = 96}) {
    if (url.isEmpty) return const Icon(Icons.broken_image_outlined, color: Colors.grey);
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.contain,
      // 按缩略图尺寸解码，避免分类头图和表情原图占用过多内存。
      memCacheWidth: ImageDecodeSize.width(context, displayWidth),
      fadeInDuration: Duration.zero,
      fadeOutDuration: Duration.zero,
      placeholder: (_, __) => const Center(child: Icon(Icons.image_outlined, color: Colors.grey)),
      errorWidget: (_, __, ___) => const Icon(Icons.broken_image_outlined, color: Colors.grey),
    );
  }

  Widget _grid() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_failed) {
      return Center(child: TextButton(
        onPressed: () => _load(refresh: true), child: const Text('表情加载失败，点击重试'),
      ));
    }
    if (_categories.isEmpty) return const Center(child: Text('暂无官方表情'));
    final category = _categories[_selected];
    if (category.emojis.isEmpty) return const Center(child: Text('该分类暂无表情'));
    return GridView.builder(
      key: ValueKey(category.id),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisExtent: 72 + MediaQuery.textScalerOf(context).scale(12) * 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 8,
      ),
      itemCount: category.emojis.length,
      itemBuilder: (context, index) {
        final emoji = category.emojis[index];
        return InkWell(
          onTap: emoji.url.isEmpty ? null : () => widget.onSelected(emoji),
          child: Column(children: [
            Expanded(child: _image(emoji.url)),
            const SizedBox(height: 4),
            Text(emoji.description, maxLines: 2, overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
          ]),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(child: _grid()),
      if (!_loading && !_failed && _categories.isNotEmpty)
        Container(
          height: 56,
          margin: const EdgeInsets.symmetric(horizontal: 12),
          color: const Color(0xFFF0F0F0),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.all(4),
              child: InkWell(
                onTap: () => setState(() => _selected = index),
                child: Container(
                  width: 48,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(border: Border.all(
                    color: index == _selected ? const Color(0xFFFF701F) : Colors.transparent,
                    width: 2,
                  )),
                  child: _image(_categories[index].image, displayWidth: 44),
                ),
              ),
            ),
          ),
        ),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        TextButton(onPressed: widget.onCancel, child: const Text('取消')),
        TextButton(onPressed: _loading ? null : () => _load(refresh: true),
          child: const Text('刷新表情')),
      ]),
    ]);
  }
}
