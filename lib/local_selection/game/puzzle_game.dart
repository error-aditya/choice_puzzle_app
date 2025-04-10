import 'dart:ui' as ui;
// import 'dart:ui';
import 'package:choice_puzzle_app/through_api/play_session/shape_type.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'puzzle_piece.dart';
import 'background_component.dart';

class PuzzleGame extends FlameGame {
  final ui.Image puzzleImage;
  final int rows;
  final int cols;
  double boardWidth;
  double boardHeight;
  Vector2 boardOffset;
  final bool piecesInTray;
  bool _initialized = false;
  final VoidCallback? onPuzzleCompleted;
  final BuildContext context;

  @override
  void render(Canvas canvas) {
    final Rect rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final Paint paint =
        Paint()
          ..shader = LinearGradient(
            colors: [Color(0xFF1D2B64), Color(0xFFF8CDDA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(rect);
    canvas.drawRect(rect, paint);
    super.render(canvas);
  }

  PuzzleGame({
    required this.context,
    required this.puzzleImage,
    required this.rows,
    required this.cols,
    required this.boardWidth,
    required this.boardHeight,
    required this.boardOffset,
    this.piecesInTray = true,
    this.onPuzzleCompleted,
  }) {
    _setInitialLayout();
  }
  void _setInitialLayout() {
    final mediaSize = MediaQuery.of(context).size;
    final screenWidth = mediaSize.width;
    final screenHeight = mediaSize.height;

    boardWidth = screenWidth * 0.84;
    boardHeight = screenHeight * 0.39;
    boardOffset = Vector2((screenWidth - boardWidth) / 2, screenHeight * 0.09);
  }

  @override
  Future<void> onLoad() async {
    if (_initialized) return;
    _initialized = true;
    await super.onLoad();
    children.clear();
    add(
      BackgroundComponent(
        position: boardOffset,
        width: boardWidth,
        height: boardHeight,
      ),
    );
    _createPieces();
  }

  void _createPieces() async {
    final pieceWidth = boardWidth / cols;
    final pieceHeight = boardHeight / rows;
    final trayStartY = boardOffset.y + boardHeight + 0;

    List<Vector2> trayPositions = [];
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        trayPositions.add(
          Vector2(boardOffset.x + j * pieceWidth, trayStartY + i * pieceHeight),
        );
      }
    }
    trayPositions.shuffle();

    List<List<Shape>> shapeGrid = List.generate(
      rows,
      (_) => List.generate(
        cols,
        (_) => Shape(topTab: 0, rightTab: 0, bottomTab: 0, leftTab: 0),
      ),
    );

    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        final int pieceIndex = i * cols + j;
        final srcX = (j * puzzleImage.width / cols).toDouble();
        final srcY = (i * puzzleImage.height / rows).toDouble();
        final srcWidth = (puzzleImage.width / cols).toDouble();
        final srcHeight = (puzzleImage.height / rows).toDouble();

        final sprite = Sprite(
          puzzleImage,
          srcPosition: Vector2(srcX, srcY),
          srcSize: Vector2(srcWidth, srcHeight),
        );

        final correctPosition =
            boardOffset + Vector2(j * pieceWidth, i * pieceHeight);
        final initialPosition =
            piecesInTray ? trayPositions.removeAt(0) : correctPosition.clone();

        // Ensuring pieces interlock correctly
        final shape = Shape(
          topTab:
              (i == 0)
                  ? 0
                  : -shapeGrid[i - 1][j]
                      .bottomTab, // Match top with the above piece's bottom
          rightTab:
              (j == cols - 1)
                  ? 0
                  : (j.isEven ? 1 : -1), // Alternating pattern for right
          bottomTab:
              (i == rows - 1)
                  ? 0
                  : (i.isEven ? 1 : -1), // Alternating pattern for bottom
          leftTab:
              (j == 0)
                  ? 0
                  : -shapeGrid[i][j - 1]
                      .rightTab, // Match left with the left piece's right
        );

        shapeGrid[i][j] = shape;

        final piece = PuzzlePiece(
          sprite: sprite,
          correctPosition: correctPosition,
          size: Vector2(pieceWidth, pieceHeight),
          position: initialPosition,
          pieceIndex: pieceIndex,
          shape: shape,
          rows: rows,
          colums: cols,
        );

        add(piece);
      }
    }
  }

  void checkIfSolved() async {
    int placedCount =
        children
            .whereType<PuzzlePiece>()
            .where((p) => p.isPlaced)
            .length
            .toInt();
    int totalPieces = rows * cols;
    if (placedCount == totalPieces) {
      _showCompletionDialog();
    }
  }

  bool isPuzzleSolved() {
    return children.whereType<PuzzlePiece>().every((p) => p.isPlaced);
  }

  void _showCompletionDialog() {
    overlays.add('PuzzleCompleted');
  }

  void updateLayout(double gameWidth, double gameHeight) {
    onGameResize(Vector2(gameWidth, gameHeight));
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    boardWidth = screenWidth * 0.84;
    boardHeight = screenHeight * 0.39;

    boardOffset = Vector2((screenWidth - boardWidth) / 2, screenHeight * 0.08);

    // Update background
    for (final bg in children.whereType<BackgroundComponent>()) {
      bg.position = boardOffset;
      bg.width = boardWidth;
      bg.height = boardHeight;
    }

    final pieceWidth = boardWidth / cols;
    final pieceHeight = boardHeight / rows;
    final trayStartY = boardOffset.y + boardHeight + 16;

    final trayPiecesPerRow = (screenWidth / pieceWidth).floor();
    final trayMarginX = (screenWidth - trayPiecesPerRow * pieceWidth) / 2;

    final pieces = children.whereType<PuzzlePiece>().toList()..shuffle();
    for (int index = 0; index < pieces.length; index++) {
      final piece = pieces[index];
      final int i = piece.pieceIndex ~/ cols;
      final int j = piece.pieceIndex % cols;

      piece.correctPosition =
          boardOffset + Vector2(j * pieceWidth, i * pieceHeight);
      piece.size = Vector2(pieceWidth, pieceHeight);

      if (!piece.isPlaced) {
        piece.position = Vector2(
          trayMarginX + (index % trayPiecesPerRow) * pieceWidth,
          trayStartY + (index ~/ trayPiecesPerRow) * pieceHeight,
        );
      }
    }
  }

  PuzzlePiece? getPieceAt(int index) {
    return children.whereType<PuzzlePiece>().firstWhere(
      (piece) => piece.pieceIndex == index,
      orElse: () => null as PuzzlePiece,
    );
  }
}
