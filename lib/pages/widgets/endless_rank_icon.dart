import 'package:flutter/material.dart';

/// 无尽模式徽章按排名选择，与旁边展示的通关层数无关。
class EndlessRankIcon extends StatelessWidget {
  const EndlessRankIcon({super.key, required this.rank, this.size = 14});

  final int rank;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (rank <= 0) return const SizedBox.shrink();
    final tier = rank <= 5 ? 1
        : rank <= 10 ? 2
        : rank <= 20 ? 3
        : rank <= 50 ? 4
        : 5;
    return Image.asset(
      'assets/rankIcon/Img_EndlessTower_Rank_$tier.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      excludeFromSemantics: true,
    );
  }
}
