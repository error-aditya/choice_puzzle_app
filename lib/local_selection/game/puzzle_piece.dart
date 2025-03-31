import 'dart:ui' as ui;
import 'package:choice_puzzle_app/local_selection/game/puzzle_game.dart';
import 'package:choice_puzzle_app/through_api/play_session/shape_type.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';

class PuzzlePiece extends PositionComponent with DragCallbacks {
  final Sprite sprite;
  Vector2 correctPosition;
  final int pieceIndex;
  final Shape shape;
  bool isPlaced = false;
  final int colums;
  final int rows;

  PuzzlePiece({
    required this.sprite,
    required this.correctPosition,
    required Vector2 size,
    required Vector2 position,
    required this.pieceIndex,
    required this.shape,
    required this.colums,
    required this.rows,
  }) : super(size: size, position: position);

  Path createJigsawPath(
    double width,
    double height,
    int leftEdge,
    int rightEdge,
    int topEdge,
    int bottomEdge,
  ) {
    Path path = Path();
    double tabSize = width * 0.25; // Adjust size of the tabs
    double tabHeight = height * 0.25; // Adjust height of the tabs

    path.moveTo(0, 0);

    // Top Edge
    if (topEdge == 0) {
      path.lineTo(width * 0.25, 0);
      path.quadraticBezierTo(width * 0.375, -tabHeight, width * 0.5, 0);
      path.quadraticBezierTo(width * 0.625, tabHeight, width * 0.75, 0);
    }
    path.lineTo(width, 0);

    // Right Edge
    if (rightEdge == 0) {
      path.lineTo(width, height * 0.25);
      path.quadraticBezierTo(
        width + tabSize,
        height * 0.375,
        width,
        height * 0.5,
      );
      path.quadraticBezierTo(
        width - tabSize,
        height * 0.625,
        width,
        height * 0.75,
      );
    }
    path.lineTo(width, height);

    // Bottom Edge
    if (bottomEdge == 0) {
      path.lineTo(width * 0.75, height);
      path.quadraticBezierTo(
        width * 0.625,
        height + tabHeight,
        width * 0.5,
        height,
      );
      path.quadraticBezierTo(
        width * 0.375,
        height - tabHeight,
        width * 0.25,
        height,
      );
    }
    path.lineTo(0, height);

    // Left Edge
    if (leftEdge == 0) {
      path.lineTo(0, height * 0.75);
      path.quadraticBezierTo(-tabSize, height * 0.625, 0, height * 0.5);
      path.quadraticBezierTo(tabSize, height * 0.375, 0, height * 0.25);
    }

    path.close();
    return path;
  }

  @override
  void render(Canvas canvas) {
    Paint paint = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2.0;

    bool isLeftEdge = pieceIndex % colums == 0;
    bool isRightEdge = (pieceIndex + 1) % colums == 0;
    bool isTopEdge = pieceIndex < colums;
    bool isBottomEdge = pieceIndex >= (rows - 1) * colums;

    canvas.save();

    Path clipPath = createJigsawPath(
      size.x,
      size.y,
      isLeftEdge ? 1 : 0,
      isRightEdge ? 1 : 0,
      isTopEdge ? 1 : 0,
      isBottomEdge ? 1 : 0,
    );
    canvas.clipPath(clipPath);

    drawNeighboringTexture(
      canvas,
      isLeftEdge,
      isRightEdge,
      isTopEdge,
      isBottomEdge,
    );

    sprite.render(canvas, size: size);

    canvas.drawPath(clipPath, paint);
    canvas.restore();
  }

  void drawNeighboringTexture(
    Canvas canvas,
    bool left,
    bool right,
    bool top,
    bool bottom,
  ) {
    final gameRef = findGame() as PuzzleGame?;
    if (gameRef == null) return;

    double tabSize = size.x * .01;
    double tabHeight = size.y * 0.01;

    // Left Neighbor
    if (!left) {
      PuzzlePiece? leftPiece = gameRef.getPieceAt(pieceIndex - 1);
      if (leftPiece != null) {
        canvas.save();
        canvas.translate(-size.x + tabSize, .1);
        leftPiece.sprite.render(canvas, size: size);
        canvas.restore();
      }
    }

    // Right Neighbor
    if (!right) {
      PuzzlePiece? rightPiece = gameRef.getPieceAt(pieceIndex + 1);
      if (rightPiece != null) {
        canvas.save();
        canvas.translate(size.x - tabSize, 0);
        rightPiece.sprite.render(canvas, size: size);
        canvas.restore();
      }
    }

    // Top Neighbor
    if (!top) {
      PuzzlePiece? topPiece = gameRef.getPieceAt(pieceIndex - colums);
      if (topPiece != null) {
        canvas.save();
        canvas.translate(0, -size.y + tabHeight);
        topPiece.sprite.render(canvas, size: size);
        canvas.restore();
      }
    }

    // Bottom Neighbor
    if (!bottom) {
      PuzzlePiece? bottomPiece = gameRef.getPieceAt(pieceIndex + colums);
      if (bottomPiece != null) {
        canvas.save();
        canvas.translate(0, size.y - tabHeight);
        bottomPiece.sprite.render(canvas, size: size);
        canvas.restore();
      }
    }
  }

  void snapToCorrectPosition() {
    position = correctPosition;
    isPlaced = true;
    print("✅ Piece $pieceIndex placed correctly!");

    final gameRef = findGame() as PuzzleGame?;
    gameRef?.checkIfSolved();
    
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (!isPlaced) {
      position.add(event.delta);
    }
  }

  bool isCorrectlyPlaced() {
    return (position - correctPosition).length < 5.0;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (isCorrectlyPlaced()) {
    FlameAudio.play('click.wav',volume: 1,);
      snapToCorrectPosition();
    } else {
      print("❌ Piece $pieceIndex is NOT in correct position.");
    }

    final gameRef = findGame() as PuzzleGame?;
    gameRef?.checkIfSolved();
  }
}