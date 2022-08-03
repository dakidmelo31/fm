import 'package:flutter/material.dart';
import 'package:merchants/widgets/reveal_home.dart';

class Home extends StatefulWidget {
  static const routeName = "/home";
  const Home({Key? key}) : super(key: key);

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
        child: RevealWidget());
  }
}
