import 'package:flutter/material.dart';

class VerticalSizeTransition extends PageRouteBuilder {
  VerticalSizeTransition({required this.child})
      : super(
            pageBuilder: (_, animation, anotherAnimation) {
              animation = CurvedAnimation(
                  parent: animation, curve: Curves.fastLinearToSlowEaseIn);
              return SizeTransition(
                sizeFactor: animation,
                axis: Axis.vertical,
                axisAlignment: 0.0,
                child: child,
              );
            },
            transitionsBuilder: (_, animation, anotherAnimation, child) {
              animation = CurvedAnimation(
                  parent: animation, curve: Curves.fastLinearToSlowEaseIn);
              return SizeTransition(
                sizeFactor: animation,
                axis: Axis.vertical,
                axisAlignment: 0.0,
                child: child,
              );
            },
            transitionDuration: const Duration(
              milliseconds: 1200,
            ),
            opaque: false,
            barrierColor: Colors.black.withOpacity(.6));

  final Widget child;
}

class HorizontalSizeTransition extends PageRouteBuilder {
  HorizontalSizeTransition({required this.child})
      : super(
            pageBuilder: (_, animation, anotherAnimation) {
              animation = CurvedAnimation(
                  parent: animation, curve: Curves.fastLinearToSlowEaseIn);
              return SizeTransition(
                sizeFactor: animation,
                axis: Axis.horizontal,
                axisAlignment: 0.0,
                child: child,
              );
            },
            transitionsBuilder: (_, animation, anotherAnimation, child) {
              animation = CurvedAnimation(
                  parent: animation, curve: Curves.fastLinearToSlowEaseIn);
              return SizeTransition(
                sizeFactor: animation,
                axis: Axis.horizontal,
                axisAlignment: 0.0,
                child: child,
              );
            },
            transitionDuration: const Duration(
              milliseconds: 1200,
            ),
            opaque: false,
            barrierColor: Colors.black.withOpacity(.6));

  final Widget child;
}

class CustomScaleTransition extends PageRouteBuilder {
  CustomScaleTransition({required this.child, required this.alignment})
      : super(
            pageBuilder: (_, animation, anotherAnimation) {
              animation = CurvedAnimation(
                  parent: animation, curve: Curves.fastLinearToSlowEaseIn);
              return ScaleTransition(
                scale: animation,
                alignment: alignment,
                filterQuality: FilterQuality.high,
                child: child,
              );
            },
            transitionsBuilder: (_, animation, anotherAnimation, child) {
              animation = CurvedAnimation(
                  parent: animation, curve: Curves.fastLinearToSlowEaseIn);
              return ScaleTransition(
                scale: animation,
                alignment: alignment,
                child: child,
              );
            },
            transitionDuration: const Duration(
              milliseconds: 1200,
            ),
            opaque: false,
            barrierColor: Colors.black.withOpacity(.6));

  final Widget child;
  final Alignment alignment;
}

class CustomFadeTransition extends PageRouteBuilder {
  CustomFadeTransition({required this.child})
      : super(
            pageBuilder: (_, animation, anotherAnimation) {
              animation = CurvedAnimation(
                  parent: animation, curve: Curves.fastLinearToSlowEaseIn);
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionsBuilder: (_, animation, anotherAnimation, child) {
              animation = CurvedAnimation(
                  parent: animation, curve: Curves.fastLinearToSlowEaseIn);
              return SizeTransition(
                sizeFactor: animation,
                axis: Axis.horizontal,
                axisAlignment: 0.0,
                child: child,
              );
            },
            transitionDuration: const Duration(
              milliseconds: 1500,
            ),
            reverseTransitionDuration: const Duration(milliseconds: 600),
            opaque: false,
            barrierColor: Colors.black.withOpacity(.6));

  final Widget child;
}
