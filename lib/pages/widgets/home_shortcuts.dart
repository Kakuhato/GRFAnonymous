import 'package:flutter/material.dart';

class HomeShortcuts extends StatelessWidget {
  const HomeShortcuts({
    super.key,
    required this.isSignedIn,
    this.isSigningIn = false,
    required this.onSignIn,
    required this.onShop,
  });

  final bool isSignedIn;
  final bool isSigningIn;
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
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onSignIn,
            child: Column(
              children: [
                Stack(
                  children: [
                    Image.asset(
                      isSignedIn ? 'assets/sign-in-ed.png' : 'assets/sign-in.png',
                      height: 62,
                    ),
                    if (!isSignedIn && !isSigningIn)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Colors.red, shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                Text(isSignedIn ? '已签到' : isSigningIn ? '签到中…' : '签到',
                    style: TextStyle(color: isSignedIn ? Colors.grey : null)),
              ],
            ),
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
