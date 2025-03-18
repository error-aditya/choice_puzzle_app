import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/game.dart';
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

  PuzzleGame({
    required this.puzzleImage,
    required this.rows,
    required this.cols,
    required this.boardWidth,
    required this.boardHeight,
    required this.boardOffset,
    this.piecesInTray = true,
  });

  @override
  Future<void> onLoad() async {
    if (_initialized) return;
    _initialized = true;
    await super.onLoad();

    // Clear any previously added components.
    children.clear();

    // Add the background board.
    add(
      BackgroundComponent(
        position: boardOffset,
        width: boardWidth,
        height: boardHeight,
      ),
    );

    // Create exactly rows x cols puzzle pieces.
    _createPieces();
  }

  // Create puzzle pieces arranged in a grid.
  void _createPieces() {
    final pieceWidth = boardWidth / cols;
    final pieceHeight = boardHeight / rows;
    // For initial creation, place pieces in a tray immediately below the board.
    final trayStartY = boardOffset.y + boardHeight + 30;
    // Initially, we assume 'cols' pieces per row (this will be updated in onGameResize).
    int index = 0;

    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        final srcX = (j * puzzleImage.width / cols).toDouble();
        final srcY = (i * puzzleImage.height / rows).toDouble();
        final srcWidth = (puzzleImage.width / cols).toDouble();
        final srcHeight = (puzzleImage.height / rows).toDouble();

        final sprite = Sprite(
          puzzleImage,
          srcPosition: Vector2(srcX, srcY),
          srcSize: Vector2(srcWidth, srcHeight),
        );

        // The correct (target) position on the board.
        final correctPosition =
            boardOffset + Vector2(j * pieceWidth, i * pieceHeight);

        // If piecesInTray is true, arrange them in a grid in the tray;
        // here, initially use exactly 'cols' pieces per row.
        final initialPosition =
            piecesInTray
                ? Vector2(
                  boardOffset.x + (index % cols) * pieceWidth,
                  trayStartY + (index ~/ cols) * pieceHeight,
                )
                : correctPosition.clone();
        index++;

        final piece = PuzzlePiece(
          sprite: sprite,
          correctPosition: correctPosition,
          size: Vector2(pieceWidth, pieceHeight),
          position: initialPosition,
          pieceIndex: index,
        );
        add(piece);
      }
    }
  }

  void updateLayout(double gameWidth, double gameHeight) {
    onGameResize(Vector2(gameWidth, gameHeight));
  }

  // onGameResize recalculates layout when the canvas size changes (e.g. on rotation).
  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);
    final gameWidth = canvasSize.x;
    final gameHeight = canvasSize.y;

    // Set board dimensions: make the board 60% of the game width (square).
    boardWidth = gameWidth * 0.73;
    boardHeight = boardWidth;
    // Center the board horizontally and place it near the top (e.g. 15% from the top).
    boardOffset = Vector2((gameWidth - boardWidth) / 2, gameHeight * 0.15);

    // Update the background board.
    for (final bg in children.whereType<BackgroundComponent>()) {
      bg.position = boardOffset;
      bg.width = boardWidth;
      bg.height = boardHeight;
    }

    // Tray: place unsnapped pieces below the board.
    final trayStartY = boardOffset.y + boardHeight + 100;
    final pieceWidth = boardWidth / cols;
    final pieceHeight = boardHeight / rows;

    // Calculate how many pieces fit horizontally in the tray.
    // If there isn't enough space, pieces will wrap into the next row.
    final trayPiecesPerRow = (gameWidth / pieceWidth).floor();
    final trayMarginX = (gameWidth - trayPiecesPerRow * pieceWidth) / 2;

    // Get the pieces sorted by pieceIndex.
    final pieces =
        children.whereType<PuzzlePiece>().toList()
          ..sort((a, b) => a.pieceIndex.compareTo(b.pieceIndex));

    // Update each piece's target position and tray position if not snapped.
    for (int index = 0; index < pieces.length; index++) {
      final piece = pieces[index];
      final int i = index ~/ cols; // Target row on board.
      final int j = index % cols; // Target column on board.
      piece.correctPosition =
          boardOffset + Vector2(j * pieceWidth, i * pieceHeight);
      if (!piece.isPlaced) {
        piece.position = Vector2(
          trayMarginX + (index % trayPiecesPerRow) * pieceWidth,
          trayStartY + (index ~/ trayPiecesPerRow) * pieceHeight,
        );
      }
    }
  }
}
