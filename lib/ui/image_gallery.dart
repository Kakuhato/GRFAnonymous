import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../utils/image_actions.dart';

/// 列表和正文共用的图片预览入口，保留图片顺序及被点击的位置。
Future<void> showImageGallery(
  BuildContext context, {
  required List<String> images,
  int initialIndex = 0,
}) async {
  if (images.isEmpty) return;
  await showDialog<void>(
    context: context,
    useSafeArea: false,
    barrierColor: Colors.black54,
    builder: (_) => _ImageGallery(
      images: List<String>.of(images),
      initialIndex: initialIndex.clamp(0, images.length - 1).toInt(),
    ),
  );
}

class _ImageGallery extends StatefulWidget {
  const _ImageGallery({required this.images, required this.initialIndex});

  final List<String> images;
  final int initialIndex;

  @override
  State<_ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<_ImageGallery> {
  late final PageController _pages;
  final _transform = TransformationController();
  final _viewportKey = GlobalKey();
  late int _index;
  double _scale = 1;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _pages = PageController(initialPage: _index);
    _transform.addListener(_onTransform);
  }

  void _onTransform() {
    final scale = _transform.value.getMaxScaleOnAxis();
    if ((scale - _scale).abs() > 0.001) {
      setState(() => _scale = scale);
    }
  }

  void _zoom(double scale) {
    final targetScale = scale.clamp(1.0, 4.0).toDouble();
    final size = _viewportKey.currentContext?.size ?? Size.zero;
    _transform.value = Matrix4.identity()
      ..translate(
        size.width * (1 - targetScale) / 2,
        size.height * (1 - targetScale) / 2,
      )
      ..scale(targetScale);
  }

  void _goTo(int index) {
    if (index < 0 || index >= widget.images.length) return;
    _zoom(1);
    _pages.animateToPage(
      index,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  void _close() => Navigator.of(context).pop();

  @override
  void dispose() {
    _transform.removeListener(_onTransform);
    _transform.dispose();
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _close,
      child: Material(
      type: MaterialType.transparency,
      child: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                tooltip: '关闭图片预览',
                color: Colors.white,
                onPressed: _close,
                icon: const Icon(Icons.close),
              ),
            ),
            Expanded(
              child: PageView.builder(
                key: _viewportKey,
                controller: _pages,
                itemCount: widget.images.length,
                // 放大后滑动用于平移图片；还原后滑动用于切换图片。
                physics: _scale > 1.01
                    ? const NeverScrollableScrollPhysics()
                    : const PageScrollPhysics(),
                onPageChanged: (index) {
                  _zoom(1);
                  setState(() => _index = index);
                },
                itemBuilder: (context, index) {
                  return InteractiveViewer(
                    transformationController:
                        index == _index ? _transform : null,
                    minScale: 1,
                    maxScale: 4,
                    panEnabled: _scale > 1.01,
                    child: SizedBox.expand(
                      child: CachedNetworkImage(
                        imageUrl: widget.images[index],
                        fit: BoxFit.contain,
                        // 点击图片本身不关闭；实际图片外的留白交给蒙版处理。
                        imageBuilder: (context, provider) => Center(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {},
                            // 双击与长按只命中图片，避免蒙版单击等待双击判定。
                            onDoubleTap: () => _zoom(_scale > 1.01 ? 1 : 2),
                            onLongPress: () => ImageActions.showSaveMenu(
                              context, widget.images[index],
                            ),
                            child: Image(
                              image: provider,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        placeholder: (_, __) => const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                        errorWidget: (_, __, ___) => const Center(
                          child: Text('图片加载失败',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: GestureDetector(
                // 工具栏内的空隙也不属于蒙版。
                onTap: () {},
                behavior: HitTestBehavior.opaque,
                child: Material(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(24),
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  alignment: WrapAlignment.center,
                  children: [
                    IconButton(
                      tooltip: '上一张',
                      color: Colors.white,
                      disabledColor: Colors.white30,
                      onPressed: _index > 0 ? () => _goTo(_index - 1) : null,
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Text('${_index + 1} / ${widget.images.length}',
                        style: const TextStyle(color: Colors.white)),
                    IconButton(
                      tooltip: '下一张',
                      color: Colors.white,
                      disabledColor: Colors.white30,
                      onPressed: _index < widget.images.length - 1
                          ? () => _goTo(_index + 1) : null,
                      icon: const Icon(Icons.chevron_right),
                    ),
                    IconButton(
                      tooltip: '缩小',
                      color: Colors.white,
                      onPressed: () => _zoom(_scale / 1.5),
                      icon: const Icon(Icons.zoom_out),
                    ),
                    TextButton(
                      onPressed: () => _zoom(1),
                      child: Text('${(_scale * 100).round()}%',
                          style: const TextStyle(color: Colors.white)),
                    ),
                    IconButton(
                      tooltip: '放大',
                      color: Colors.white,
                      onPressed: () => _zoom(_scale * 1.5),
                      icon: const Icon(Icons.zoom_in),
                    ),
                    IconButton(
                      tooltip: '保存当前图片',
                      color: Colors.white,
                      onPressed: () => ImageActions.showSaveMenu(
                        context, widget.images[_index],
                      ),
                      icon: const Icon(Icons.download_outlined),
                    ),
                  ],
                ),
              ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
