import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../game/puzzle_game.dart';

class PuzzleGameScreen extends StatefulWidget {
  final Uint8List imageBytes;
  final int rows;
  final int cols;

  const PuzzleGameScreen({
    Key? key,
    required this.imageBytes,
    required this.rows,
    required this.cols,
  }) : super(key: key);

  @override
  _PuzzleGameScreenState createState() => _PuzzleGameScreenState();
}

class _PuzzleGameScreenState extends State<PuzzleGameScreen> {
  PuzzleGame? game;
  bool gameLoaded = false;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  Future<ui.Image> _loadImage(Uint8List bytes) async {
    return await decodeImageFromList(bytes);
  }


  Future<void> _initializeGame() async {
    final puzzleImage = await _loadImage(widget.imageBytes);
    // Initialize with temporary values; we'll update layout responsively.
    game = PuzzleGame(
      puzzleImage: puzzleImage,
      rows: widget.rows,
      cols: widget.cols,
      boardWidth: 289.0,
      boardHeight: 289.0,
      boardOffset: Vector2(20, 20),
      piecesInTray: true,
    );
    await game!.onLoad();
    setState(() {
      gameLoaded = true;
    });
  }

  // Function to show the reference image.
  void _showReferenceImage() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            content: Image.memory(widget.imageBytes),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!gameLoaded || game == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Puzzle Game")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    // Use LayoutBuilder to get the current available width and height.
    return OrientationBuilder(
      builder: (context, orientation) {
        final size = MediaQuery.of(context).size;
        // For example, set the game area to use full width and 80% of height.
        final gameWidth = size.width;
        final gameHeight = size.height;

        // Optionally, you can update your game dimensions here.
        game!.updateLayout(
          size.width,
          size.height,
        ); // Update game dimensions here., gameHeight);

        return Scaffold(
          appBar: AppBar(title: const Text("Puzzle Game")),
          body: Center(
            child: SizedBox(
              width: gameWidth,
              height: gameHeight,
              child: GameWidget(game: game!),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _showReferenceImage,
            child: const Icon(Icons.image),
          ),
        );
      },
    );
  }
}
