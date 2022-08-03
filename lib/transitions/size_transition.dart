import 'package:flutter/widgets.dart';

class LeftSlideTransition extends PageRouteBuilder {
  final Widget page;
  LeftSlideTransition({required this.page})
      : super(
            pageBuilder: (context, animation, anotherAnimation) {
              return page;
            },
            transitionDuration: Duration(seconds: 1),
            reverseTransitionDuration: Duration(milliseconds: 200),
            transitionsBuilder: (context, animation, anotherAnimation, child) {
              animation = CurvedAnimation(
                  parent: animation,
                  curve: Curves.fastLinearToSlowEaseIn,
                  reverseCurve: Curves.fastOutSlowIn);
              return Align(
                alignment: Alignment.center,
                child: SlideTransition(
                    position:
                        Tween(begin: Offset(1.0, 0.0), end: Offset(0.0, 0.0))
                            .animate(animation)),
              );
            });
}
