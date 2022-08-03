class CatModel {
  final String image;
  final String name;
  bool selected = false;

  CatModel({required this.image, required this.name});
  toggleSelection() {
    selected = !selected;
  }
}
