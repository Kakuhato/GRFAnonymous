import 'package:flutter/widgets.dart';

/// 只控制内存解码尺寸，不改变网络 URL、磁盘原图和保存图片的质量。
class ImageDecodeSize {
  static int width(BuildContext context, double logicalWidth) {
    final width = logicalWidth.isFinite && logicalWidth > 0
        ? logicalWidth
        : MediaQuery.sizeOf(context).width;
    final pixels = width * MediaQuery.devicePixelRatioOf(context);
    // 相近布局复用同一解码尺寸，避免宽度的小数差异生成大量缓存变体。
    return ((pixels / 32).ceil() * 32).clamp(32, 4096).toInt();
  }

  static int screen(BuildContext context) =>
      width(context, MediaQuery.sizeOf(context).width);
}
