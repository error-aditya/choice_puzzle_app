import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class BackgroundComponent extends PositionComponent {
  double width;
  double height;

  BackgroundComponent({
    required Vector2 position,
    required this.width,
    required this.height,
  }) : super(position: position, size: Vector2(width, height));

  @override
  void render(Canvas canvas) {  
    final paint = Paint()
      ..color = Color(0xFFCCCCCC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawRect(size.toRect(), paint);
  }
}
