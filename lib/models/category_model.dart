import 'dart:math';

class Category {
  final String name;
  int count;
  final bool available;
  Category({required this.name, required this.count, required this.available});

  setCount() {
    count = Random().nextInt(50);
  }
}
