import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:choice_puzzle_app/local_selection/dashboard/dashboard_screen.dart';
// import 'package:choice_puzzle_app/through_api/style/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../game/puzzle_game.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:confetti/confetti.dart';

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
  int completedPuzzles = 0;
  int requiredPuzzles = 100;
  ConfettiController _confettiController = ConfettiController(
    duration: const Duration(seconds: 5),
  );
  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 5),
    );
    _initializeGame();
  }

  Future<ui.Image> _loadImage(Uint8List bytes) async {
    return await decodeImageFromList(bytes);
  }

  Future<void> _initializeGame() async {
    final prefs = await SharedPreferences.getInstance();
    String key = 'completed${widget.rows}x${widget.cols}';
    setState(() {
      completedPuzzles = prefs.getInt(key) ?? 0; // Load saved progress
    });
    final puzzleImage = await _loadImage(widget.imageBytes);
    // Initialize with temporary values; we'll update layout responsively.
    game = PuzzleGame(
      puzzleImage: puzzleImage,
      rows: widget.rows,
      cols: widget.cols,
      boardWidth: 289.0,
      boardHeight: 289.0,
      boardOffset: Vector2(20, 20),
      piecesInTray: false,
      onPuzzleCompleted: _onPuzzleCompleted,
    );
    await game!.onLoad();
    setState(() {
      gameLoaded = true;
    });
    print("🔄 Loaded completedPuzzles: $completedPuzzles");
  }

  void _onPuzzleCompleted() async {
    _confettiController.play();
    final prefs = await SharedPreferences.getInstance();
    String key = 'completed${widget.rows}x${widget.cols}';
    int currentCount = prefs.getInt(key) ?? 0;
    currentCount++;

    await prefs.setInt(key, currentCount);
    setState(() {
      completedPuzzles = currentCount;
    });
    print("Updated completedPuzzles: $completedPuzzles"); // Debug print
    _updateProgress();
  }

  Path drawStar(Size size) {
    double w = size.width, h = size.height;
    return Path()
      ..moveTo(w * 0.5, 0)
      ..lineTo(w * 0.62, h * 0.38)
      ..lineTo(w, h * 0.38)
      ..lineTo(w * 0.68, h * 0.62)
      ..lineTo(w * 0.8, h)
      ..lineTo(w * 0.5, h * 0.75)
      ..lineTo(w * 0.2, h)
      ..lineTo(w * 0.32, h * 0.62)
      ..lineTo(0, h * 0.38)
      ..lineTo(w * 0.38, h * 0.38)
      ..close();
  }

  // Function to show the reference image.
  void _showReferenceImage() {
    showDialog(
      context: context,
      useSafeArea: true,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.transparent,
            content: Image.memory(widget.imageBytes, width: 300, height: 300),
            // actions: [
            //   TextButton(
            //     onPressed: () => Navigator.pop(context),
            //     child: const Text("Close"),
            //   ),
            // ],
          ),
    );
  }

  Future<void> _updateProgress() async {
    final prefs = await SharedPreferences.getInstance();
    String key = 'completed${widget.rows}x${widget.cols}';
    await prefs.setInt(key, completedPuzzles);
    if (completedPuzzles >= requiredPuzzles) {
      await prefs.setBool('unlocked${widget.rows}x${widget.cols}', true);
    }
    print("Updated completedPuzzles: $completedPuzzles"); // Debug log
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
                      _updateProgress();
                      _onPuzzleCompleted();
                      Navigator.pop(context); // Close dialog
                      Get.off(() => DashboardScreen());
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
                  Align(
                    alignment: Alignment.center,
                    child: ConfettiWidget(
                      confettiController: _confettiController,
                      gravity: .1,
                      blastDirectionality: BlastDirectionality.explosive,
                      shouldLoop: false,
                      maxBlastForce: 50,
                      minBlastForce: 10,
                      numberOfParticles: 50,
                      emissionFrequency: 0.3,
                      createParticlePath: drawStar,
                      colors: const [
                        Colors.blue,
                        Color(0xFF24C6DC),
                        Colors.purple,
                        Colors.orange,
                        Colors.red,
                        Colors.yellow,
                        Colors.pinkAccent,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
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
                    WidgetsBinding.instance?.addPostFrameCallback((_) {
                      _showCompletionDialog();
                      _confettiController.play();
                    });
                    return Container();
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
