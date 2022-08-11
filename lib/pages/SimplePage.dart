import 'package:flutter/material.dart';

class SimplePage extends StatefulWidget {
  const SimplePage({Key? key}) : super(key: key);
  static const String routeName = "/testing";

  @override
  _SimplePageState createState() => _SimplePageState();
}

class _SimplePageState extends State<SimplePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: Container(
        child: Center(child: Text("Moved Here")),
      ),
    );
  }
}
