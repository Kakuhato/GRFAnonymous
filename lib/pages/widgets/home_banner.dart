import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:grfanonymous/models/bannerItem.dart';

class HomeBanner extends StatelessWidget {
  const HomeBanner({super.key, required this.banners});

  final List<BannerItem> banners;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      width: double.infinity,
      child: banners.isEmpty
          ? const SizedBox.shrink()
          : Swiper(
              autoplay: true,
              viewportFraction: 1,
              loop: false,
              physics: const BouncingScrollPhysics(),
              pagination: const SwiperPagination(
                builder: DotSwiperPaginationBuilder(
                  color: Color.fromRGBO(7, 6, 6, 1),
                  size: 8,
                  activeSize: 10,
                  activeColor: Color.fromRGBO(208, 104, 39, 1),
                ),
              ),
              itemCount: banners.length,
              itemBuilder: (context, index) => Container(
                margin: const EdgeInsets.all(10),
                height: 150,
                child: CachedNetworkImage(
                  imageUrl: banners[index].imgAddr,
                  fit: BoxFit.cover,
                ),
              ),
            ),
    );
  }
}
