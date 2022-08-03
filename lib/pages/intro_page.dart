import 'dart:async';

import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class Introduction extends StatefulWidget {
  const Introduction({Key? key}) : super(key: key);

  @override
  State<Introduction> createState() => _IntroductionState();
}

class _IntroductionState extends State<Introduction> {
  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.push(context,
          PageTransition(child: SecondScreen(), type: PageTransitionType.fade));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
    );
  }
}

class SecondScreen extends StatefulWidget {
  const SecondScreen({Key? key}) : super(key: key);

  @override
  State<SecondScreen> createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  bool _a = false;

  @override
  void initState() {
    Timer(Duration(milliseconds: 1800), () {
      setState(() {
        _a = !_a;
      });
    });
    Timer(Duration(milliseconds: 3500), () {
      Navigator.of(context)
          .pushReplacement(SlideTransitionAnimation(SecondPage()));
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 2000),
            curve: Curves.fastLinearToSlowEaseIn,
            width: _a ? size.width : 0.0,
            height: size.height,
            color: Colors.black,
          ),
          Center(
            child: Text("Reach Thousands Everyday"),
          )
        ]));
  }
}

class SlideTransitionAnimation extends PageRouteBuilder {
  final Widget page;
  SlideTransitionAnimation(this.page)
      : super(
            pageBuilder: (context, animation, anotherAnimation) => page,
            transitionDuration: Duration(
              milliseconds: 2000,
            ),
            transitionsBuilder: (context, animation, anotherAnimation, child) {
              animation = CurvedAnimation(
                  parent: animation, curve: Curves.fastLinearToSlowEaseIn);
              return SlideTransition(
                  position:
                      Tween(begin: Offset(1.0, 0.0), end: Offset(0.0, 0.0))
                          .animate(animation),
                  child: page);
            });
}

class SecondPage extends StatelessWidget {
  const SecondPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page"),
      ),
      body: Center(
        child: Text("This is the body of home page."),
      ),
    );
  }
}
