import 'package:flutter/material.dart';

class HomeShortcuts extends StatelessWidget {
  const HomeShortcuts({
    super.key,
    required this.isSignedIn,
    required this.onSignIn,
    required this.onShop,
  });

  final bool isSignedIn;
  final VoidCallback onSignIn;
  final VoidCallback onShop;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Stack(
                children: [
                  GestureDetector(
                    onTap: onSignIn,
                    child: Image.asset(
                      isSignedIn
                          ? 'assets/sign-in-ed.png'
                          : 'assets/sign-in.png',
                      height: 62,
                    ),
                  ),
                  if (!isSignedIn)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              const Text('签到'),
            ],
          ),
          Column(
            children: [
              GestureDetector(
                onTap: onShop,
                child: Image.asset('assets/shop.png', height: 62),
              ),
              const Text('福利兑换'),
            ],
          ),
          Column(
            children: [
              Image.asset('assets/strategy.png', height: 62),
              const Text('攻略集锦'),
            ],
          ),
          Column(
            children: [
              Image.asset('assets/data.png', height: 62),
              const Text('游戏数据'),
            ],
          ),
        ],
      ),
    );
  }
}
