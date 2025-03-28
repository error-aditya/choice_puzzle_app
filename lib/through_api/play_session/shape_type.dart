import 'dart:ui';

enum ShapeType {
  top,
  right,
  bottom,
  left,
  square, // Default shape for the image
}

class Shape {
  int topTab;
  int rightTab;
  int bottomTab;
  int leftTab;

  Shape({
    this.topTab = 0,
    this.rightTab = 0,
    this.bottomTab = 0,
    this.leftTab = 0,
  });
}