import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../models/userData.dart';

class GameHeroCard extends StatelessWidget {
  const GameHeroCard({super.key, required this.hero});

  final HeroList hero;

  @override
  Widget build(BuildContext context) {
    final imageUrl = hero.skin.trim().isNotEmpty ? hero.skin : hero.showPic;
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      final badgeSize = width * 0.2;
      // 原图四周包含边框和阴影，叠加内容需放在卡片内部。
      final contentInset = width * 0.06;
      final fallback = AspectRatio(
        aspectRatio: 0.625,
        child: Center(child: Text(hero.name, textAlign: TextAlign.center)),
      );
      return Semantics(
        label: '${hero.name}，等级 ${hero.lv}，grade ${hero.grade}',
        child: Stack(
          children: [
            // 卡面已包含角色名和底部等级栏，优先使用皮肤卡面。
            if (imageUrl.isEmpty)
              fallback
            else
              CachedNetworkImage(
                imageUrl: imageUrl,
                width: width,
                fit: BoxFit.fitWidth,
                placeholder: (_, __) => fallback,
                errorWidget: (_, __, ___) => fallback,
              ),
            Positioned(
              top: contentInset,
              right: contentInset,
              width: badgeSize,
              height: badgeSize,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset('assets/grade.png'),
                  Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '${hero.grade}',
                        textScaler: TextScaler.noScaling,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: badgeSize * 0.72,
                          height: 1,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: contentInset,
              right: contentInset,
              bottom: width * 0.065,
              child: Text(
                'lv.${hero.lv}',
                textAlign: TextAlign.center,
                textScaler: TextScaler.noScaling,
                style: TextStyle(
                  color: Colors.deepOrange,
                  fontSize: width * 0.15,
                  height: 1,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
