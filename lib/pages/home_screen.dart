import 'package:flutter/material.dart';
import 'package:merchants/widgets/reveal_home.dart';

class Home extends StatefulWidget {
  static const routeName = "/home";
  Home({Key? key, this.index}) : super(key: key);
  int? index;
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: RevealWidget(index: widget.index == null ? 0 : widget.index!));
  }
}
