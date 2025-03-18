import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class PuzzlePiece extends SpriteComponent with DragCallbacks {
  // Make correctPosition mutable.
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
    // Draw the sprite normally.
    super.render(canvas);
    // OPTIONAL: Draw an outline for debugging.
    // If the outline is causing extra visible area, you can remove or reduce it.
    // Here we draw it with a smaller stroke width and semi-transparent color.
    final paint =
        Paint()
          ..color = Colors.black.withOpacity(0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1; // Reduced stroke width.
    // Draw the outline strictly inside the bounds.
    canvas.drawRect(Offset.zero & Size(size.x, size.y), paint);
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
