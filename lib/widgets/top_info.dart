import 'package:flutter/material.dart';
import 'package:merchants/animations/opacity_tween.dart';

class TopInfo extends StatelessWidget {
  const TopInfo({Key? key, required this.mainAnimation}) : super(key: key);
  final Animation<double> mainAnimation;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return AnimatedBuilder(
      animation: mainAnimation,
      builder: (_, __) {
        return Positioned(
            top: 0,
            left: 0,
            width: size.width,
            height: size.height,
            child: Stack(
              children: [
                AnimatedBuilder(
                  animation: mainAnimation,
                  builder: (_, widget) {
                    return Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 100.0),
                        child: RotationTransition(
                            turns: CurvedAnimation(
                                parent: mainAnimation,
                                curve: Curves.fastLinearToSlowEaseIn),
                            child: widget),
                      ),
                    );
                  },
                  child: Image.asset("assets/logo.png",
                      alignment: Alignment.center, width: 60, height: 60),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  width: size.width,
                  height: size.height * .6,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TweenAnimationBuilder(
                        duration: Duration(seconds: 3),
                        tween: ColorTween(
                            begin: Colors.transparent, end: Colors.white),
                        curve: CurvedAnimation(
                                parent: mainAnimation,
                                curve:
                                    Interval(.39, .45, curve: Curves.decelerate)
                                        .curve)
                            .curve,
                        builder: (_, Color? color, child) {
                          return Text(
                            "Merchants",
                            style: TextStyle(
                                fontSize: 60 *
                                    CurvedAnimation(
                                            parent: mainAnimation,
                                            curve: Interval(.39, .45,
                                                    curve: Curves.decelerate)
                                                .curve)
                                        .value,
                                color: color),
                          );
                        },
                      ),
                      OpacityTween(
                        curve: CurvedAnimation(
                                parent: mainAnimation,
                                curve:
                                    Interval(.99, 1.0, curve: Curves.decelerate)
                                        .curve)
                            .curve,
                        child: Text(
                          "Welcome to Foodin",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ));
      },
    );
  }
}
