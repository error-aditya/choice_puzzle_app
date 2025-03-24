import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../game/puzzle_game.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';

class PuzzleGameScreen extends StatefulWidget {
  final Uint8List imageBytes;
  final int rows;
  final int cols;
  final VoidCallback? onPuzzleCompleted;

  const PuzzleGameScreen({
    Key? key,
    required this.imageBytes,
    required this.rows,
    required this.cols,
    this.onPuzzleCompleted,
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

  void _showCompletionDialog() {
    if (game is PuzzleGame) {
      (game as PuzzleGame).overlays.add('PuzzleCompleted');
    }

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 16,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "🎉 Puzzle Completed!",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Congratulations on completing the puzzle!",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      if (game is PuzzleGame) {
                        (game as PuzzleGame).overlays.remove('PuzzleCompleted');
                      }
                      
                      Navigator.pop(context); // Close dialog
                    },
                    child: const Text(
                      "OK",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green, // Text color
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!gameLoaded || game == null) {
      return Scaffold(body: const Center(child: CircularProgressIndicator()));
    }

    return OrientationBuilder(
      builder: (context, orientation) {
        final size = MediaQuery.of(context).size;
        final gameWidth = size.width;
        final gameHeight = size.height;

        game!.updateLayout(size.width, size.height);

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF24C6DC),
                    Color(0xFF514A9D),
                  ], // Cool Gradient
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            title: Shimmer.fromColors(
              baseColor: Colors.white,
              highlightColor: Colors.blue[200]!,
              child: Text(
                'PUZZLE GAME',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            centerTitle: true,
          ),
           body: Center(
            child: SizedBox(
              width: gameWidth,
              height: gameHeight,
              child: GameWidget(
                game: game!,
                overlayBuilderMap: {
                  'PuzzleCompleted': (context, game) {
                    return Center(
                      child: Container(
                        width: 250,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "🎉 Puzzle Completed!",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () {
                                if (game is PuzzleGame) {
                                  (game).overlays.remove(
                                    'PuzzleCompleted',
                                  );
                                }
                                Navigator.pop(context); // Close dialog
                              },
                              child: const Text("OK"),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                },
              ),
            ),
          ),

          floatingActionButton: FloatingActionButton(
            onPressed: _showReferenceImage,
            backgroundColor: Colors.blueAccent,
            child: const Icon(Icons.image, color: Colors.white),
          ),
        );
      },
    );
  }
}
