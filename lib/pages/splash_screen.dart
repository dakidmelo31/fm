import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            "assets/background.png",
          ),
          filterQuality: FilterQuality.high,
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Colors.transparent,
            // Colors.black,
            // Colors.black.withOpacity(.83),
            // Colors.black.withOpacity(.47),
          ],
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 90,
          height: 90,
          child: Image.asset(
            "assets/logo.png",
            alignment: Alignment.center,
            width: 80.0,
            height: 80.0,
            fit: BoxFit.scaleDown,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }
}
