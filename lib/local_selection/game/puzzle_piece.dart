import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class PuzzlePiece extends SpriteComponent with DragCallbacks {
  // Correct position is mutable.
  Vector2 correctPosition;
  bool isPlaced = false;
  final double snapThreshold = 20.0;
  final int pieceIndex;

  PuzzlePiece({
    required Sprite sprite,
    required this.correctPosition,
    required Vector2 size,
    required Vector2 position,
    required this.pieceIndex,
  }) : super(sprite: sprite, size: size, position: position);

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Optional: draw an outline for debugging.
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(size.toRect(), paint);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (!isPlaced) {
      position.add(event.delta);
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    if ((position - correctPosition).length < snapThreshold) {
      position = correctPosition.clone();
      isPlaced = true;
    }
  }
}
