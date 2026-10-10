import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:grfanonymous/ui/image_gallery.dart';

/// 单图保留比例，多图以三列宽度展示，图片原始尺寸不会决定卡片宽高。
class HomeTopicImages extends StatelessWidget {
  const HomeTopicImages({super.key, required this.images});

  final List<String> images;
  static const double _gap = 6;

  @override
  Widget build(BuildContext context) {
    final urls = images.where((url) => url.trim().isNotEmpty).toList();
    if (urls.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (urls.length == 1) {
            final width = math.min(constraints.maxWidth, 190.0);
            return GestureDetector(
              onTap: () => showImageGallery(context, images: urls),
              child: Align(
              alignment: Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: width, maxHeight: 140),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: CachedNetworkImage(
                    imageUrl: urls.single,
                    // Image 在有限约束内按原始比例计算尺寸，竖图不会拉满整行。
                    imageBuilder: (context, provider) => Image(
                      image: provider,
                      fit: BoxFit.contain,
                    ),
                    placeholder: (_, __) => SizedBox(
                      width: width,
                      height: 130,
                      child: const _ImagePlaceholder(),
                    ),
                    errorWidget: (_, __, ___) => SizedBox(
                      width: width,
                      height: 130,
                      child: const _ImagePlaceholder(failed: true),
                    ),
                  ),
                ),
              ),
              ),
            );
          }

          // 两张图片也沿用三列尺寸，避免被平均分配成两张大图。
          final side = math.min(
            140.0,
            math.max(0.0, (constraints.maxWidth - _gap * 2) / 3),
          );
          final visibleCount = math.min(urls.length, 3);
          return Row(
            children: [
              for (var index = 0; index < visibleCount; index++) ...[
                if (index > 0) const SizedBox(width: _gap),
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: SizedBox(
                    width: side,
                    height: side,
                    child: GestureDetector(
                      onTap: () => showImageGallery(
                        context, images: urls, initialIndex: index,
                      ),
                      child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: urls[index],
                          fit: BoxFit.cover,
                          placeholder: (_, __) => const _ImagePlaceholder(),
                          errorWidget: (_, __, ___) =>
                              const _ImagePlaceholder(failed: true),
                        ),
                        if (index == 2 && urls.length > visibleCount)
                          ColoredBox(
                            color: Colors.black45,
                            child: Center(
                              child: Text(
                                '+${urls.length - visibleCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({this.failed = false});

  final bool failed;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF0F0F0),
      child: Center(
        child: Icon(
          failed ? Icons.broken_image_outlined : Icons.image_outlined,
          size: 24,
          color: Colors.grey,
        ),
      ),
    );
  }
}
