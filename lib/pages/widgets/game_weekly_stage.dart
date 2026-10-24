import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../models/userData.dart';

/// 周常战绩使用浅色背景，文字位于图片右侧的留白区。
class GameWeeklyStageBanner extends StatelessWidget {
  const GameWeeklyStageBanner({super.key, required this.stage});

  final GameStageEntry stage;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 3.7,
      child: LayoutBuilder(builder: (context, constraints) {
        return Stack(
          fit: StackFit.expand,
          children: [
            if (stage.image.isEmpty)
              const Center(child: Icon(Icons.image_not_supported_outlined, color: Colors.grey))
            else
              CachedNetworkImage(
                imageUrl: stage.image,
                fit: BoxFit.cover,
                placeholder: (_, __) => const Center(child: Icon(Icons.image_outlined, color: Colors.grey)),
                errorWidget: (_, __, ___) => const Center(child: Icon(Icons.broken_image_outlined, color: Colors.grey)),
              ),
            Positioned(
              left: constraints.maxWidth * 0.45,
              right: 24,
              top: constraints.maxHeight * 0.18,
              bottom: constraints.maxHeight * 0.22,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(stage.name, style: const TextStyle(
                      color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold,
                    )),
                    if (stage.detail.isNotEmpty)
                      Text(stage.detail, style: const TextStyle(
                        color: Color(0xFFCC2020), fontSize: 15,
                      )),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class GameWeeklyStageCarousel extends StatefulWidget {
  const GameWeeklyStageCarousel({super.key, required this.stages, this.stageBuilder});

  final List<GameStageEntry> stages;
  final Widget Function(BuildContext context, GameStageEntry stage)? stageBuilder;

  @override
  State<GameWeeklyStageCarousel> createState() => _GameWeeklyStageCarouselState();
}

class _GameWeeklyStageCarouselState extends State<GameWeeklyStageCarousel> {
  final _controller = PageController(keepPage: false);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _move(int direction) {
    if (!_controller.hasClients || !_controller.position.hasContentDimensions || widget.stages.isEmpty) return;
    final page = (_controller.page ?? 0).round();
    final target = (page + direction).clamp(0, widget.stages.length - 1).toInt();
    _controller.animateToPage(
      target,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  Widget _arrow({required bool left}) {
    return Align(
      alignment: left ? Alignment.centerLeft : Alignment.centerRight,
      child: Semantics(
        button: true,
        label: left ? '上一项战绩' : '下一项战绩',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _move(left ? -1 : 1),
          child: SizedBox(
            width: 24,
            height: 48,
            child: Center(
              child: Image.asset(
                left ? 'assets/leftArrow.png' : 'assets/rightArrow.png',
                width: 20,
                height: 36,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.stages.isEmpty) return const SizedBox.shrink();
    // 两侧各预留 12，箭头中心落在图片边界上，外侧部分仍可点击。
    return LayoutBuilder(builder: (context, constraints) => SizedBox(
      height: (constraints.maxWidth - 24) / 3.7,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: PageView.builder(
              controller: _controller,
              itemCount: widget.stages.length,
              itemBuilder: (context, index) => widget.stageBuilder?.call(context, widget.stages[index])
                  ?? GameWeeklyStageBanner(stage: widget.stages[index]),
            ),
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final page = _controller.hasClients && _controller.position.hasContentDimensions
                  ? (_controller.page ?? 0.0)
                  : 0.0;
              return Stack(
                children: [
                  if (widget.stages.length > 1 && page > 0.001) _arrow(left: true),
                  if (widget.stages.length > 1 && page < widget.stages.length - 1 - 0.001) _arrow(left: false),
                ],
              );
            },
          ),
        ],
      ),
    ));
  }
}
