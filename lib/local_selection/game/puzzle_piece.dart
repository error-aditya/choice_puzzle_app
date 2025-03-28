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
    double tabWidth = width * 0.2;
    double tabHeight = height * 0.2;

    path.moveTo(0, 0);

    if (topEdge == 0) {
      path.lineTo(width * 0.3, 0);
      path.quadraticBezierTo(width * 0.5, tabHeight, width * 0.7, 0);
    }
    path.lineTo(width, 0);

    if (rightEdge == 0) {
      path.lineTo(width, height * 0.3);
      path.quadraticBezierTo(width - tabWidth, height * 0.5, width, height * 0.7);
    }
    path.lineTo(width, height);

    if (bottomEdge == 0) {
      path.lineTo(width * 0.7, height);
      path.quadraticBezierTo(width * 0.5, height + tabHeight, width * 0.3, height);
    }
    path.lineTo(0, height);

    if (leftEdge == 0) {
      path.lineTo(0, height * 0.7);
      path.quadraticBezierTo(-tabWidth, height * 0.5, 0, height * 0.3);
    }

    path.close();
    return path;
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint();

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

    drawNeighboringTexture(canvas, isLeftEdge, isRightEdge, isTopEdge, isBottomEdge);

    sprite.render(canvas, size: size);

    canvas.restore();
  }

  void drawNeighboringTexture(Canvas canvas, bool left, bool right, bool top, bool bottom) {
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
        canvas.translate(size.x  -tabSize, 0);
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
    if (isCorrectlyPlaced()) {
      snapToCorrectPosition();
    } else {
      print("❌ Piece $pieceIndex is NOT in correct position.");
    }

    final gameRef = findGame() as PuzzleGame?;
    gameRef?.checkIfSolved();
  }
}
