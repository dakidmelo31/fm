import 'package:flutter/material.dart';
import "dart:math" as math;

import 'package:merchants/animations/slideup_tween.dart';


class ChooseOption extends StatelessWidget {
  const ChooseOption(
      {Key? key,
      required this.mainAnimation,
      required this.switchAnimation,
      required this.onAnimationStarted})
      : super(key: key);
  final Animation<double> mainAnimation, switchAnimation;
  final VoidCallback onAnimationStarted;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final bottomPosition = -150 * (1 - mainAnimation.value);
    return AnimatedBuilder(
        animation: Listenable.merge([mainAnimation, switchAnimation]),
        builder: (_, __) {
          final h = 250 *
              (CurvedAnimation(
                              parent: mainAnimation,
                              curve:
                                  Interval(0.0, 1.0, curve: Curves.decelerate))
                          .value -
                      1)
                  .abs();
          final centerLeft = (size.width - 250) / 2;
          final topExitPosition = size.height * switchAnimation.value;
          final exitHeight = size.height * switchAnimation.value;
          final circleSize = size.height * math.pow((switchAnimation.value), 2);

          // debugPrint(mainAnimation.value.toString());
          return Positioned(
              bottom: -size.height / ((1.3 * mainAnimation.value) + .01),
              width: size.width +
                  ((size.width * 2) *
                      CurvedAnimation(
                              parent: mainAnimation,
                              curve:
                                  Interval(.73, 1.0, curve: Curves.decelerate))
                          .value),
              height: size.height + circleSize + exitHeight,
              child: ClipOval(
                // borderRadius: BorderRadius.circular(460 * mainAnimation.value),
                child: Container(
                  color: Colors.white,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                        padding: const EdgeInsets.only(top: 25.0),
                        child: AnimatedBuilder(
                            animation: switchAnimation,
                            builder: (_, child) {
                              return SlideUpTween(
                                curve: CurvedAnimation(
                                  parent: mainAnimation,
                                  curve: Interval(
                                    .87,
                                    1.0,
                                    curve: Curves.decelerate,
                                  ),
                                ).curve,
                                begin: Offset(-200, 300),
                                child: Column(
                                  children: [
                                    AnimatedScale(
                                      duration: Duration(milliseconds: 300),
                                      scale: (1 - switchAnimation.value * 6),
                                      child: Card(
                                        color: Colors.white,
                                        shadowColor:
                                            Colors.grey.withOpacity(.25),
                                        elevation: CurvedAnimation(
                                              parent: mainAnimation,
                                              curve: Interval(.88, 1.0,
                                                  curve: Curves.bounceInOut),
                                            ).value *
                                            15,
                                        child: InkWell(
                                          onTap: onAnimationStarted,
                                          child: SizedBox(
                                            width: size.width - 80,
                                            height: 60,
                                            child: Center(
                                              child: Text(
                                                "Start Selling Now!",
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            })),
                  ),
                ),
              ));
        });
  }
}
