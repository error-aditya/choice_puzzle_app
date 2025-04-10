import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:choice_puzzle_app/controllers/progress_category_controller.dart';
import 'package:flame_audio/flame_audio.dart';
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
  final String category;
  final int cols;
  final VoidCallback? onPuzzleCompleted;
  final bool isReplay;

  const PuzzleGameScreen({
    Key? key,
    required this.imageBytes,
    required this.rows,
    required this.category,
    required this.cols,
    this.onPuzzleCompleted,
    this.isReplay = false,
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
    duration: const Duration(seconds: 1),
  );

  final PuzzleProgressController puzzleProgressController = Get.find();
  AudioPlayer? _player;

  @override
  void initState() {
    super.initState();
    FlameAudio.play('game_start.mp3', volume: 1);
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 1),
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
      context: context,
      boardWidth: 330.0,
      boardHeight: 310.0,
      boardOffset: Vector2(25, 0),
      piecesInTray: true,
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
    if (!widget.isReplay) {
      final prefs = await SharedPreferences.getInstance();
      String key = 'completed${widget.rows}x${widget.cols}';
      int currentCount = prefs.getInt(key) ?? 0;
      currentCount++;

      await puzzleProgressController.updatePuzzleCompletion(
        widget.category,
        widget.rows,
        widget.cols,
        currentCount,
        requiredPuzzles,
      );
      setState(() {
        completedPuzzles = currentCount;
      });
      await _updateProgress(); // Save updated progress
    } else {
      print("✅ Play Again mode: Progress count is not updated.");
    }
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
  bool isDialogOpen = false; // Add this flag

  void _showReferenceImage() {
    if (isDialogOpen) return;

    isDialogOpen = true;
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent accidental dismiss
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          content: Image.memory(widget.imageBytes, width: 300, height: 300),
        );
      },
    ).then((_) {
      isDialogOpen = false; // Reset flag when dialog is dismissed
    });
  }

  void _hideReferenceImage() {
    if (isDialogOpen) {
      Navigator.of(context).pop(); // Close the dialog if it's open
      isDialogOpen = false;
    }
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
      barrierDismissible: false,
      builder:
          (context) => WillPopScope(
            onWillPop: () async => false,
            child: Dialog(
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
                      onPressed: () async {
                        if (game is PuzzleGame) {
                          (game as PuzzleGame).overlays.remove(
                            'PuzzleCompleted',
                          );
                        }
                        _updateProgress();
                        _onPuzzleCompleted();
                        await _player?.stop(); // In OK button
                        Navigator.pop(context);
                        Navigator.pop(context);
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
                      alignment: Alignment.topCenter,
                      child: ConfettiWidget(
                        confettiController: _confettiController,
                        gravity: .1,
                        blastDirectionality: BlastDirectionality.explosive,
                        shouldLoop: false,
                        maxBlastForce: 50,
                        minBlastForce: 10,
                        numberOfParticles: 100,
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
          ),
    );
  }

  @override
  void dispose() {
    _confettiController.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!gameLoaded || game == null) {
      return Scaffold(body: const Center(child: CircularProgressIndicator()));
    }
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        bool shouldExit = await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: const Color(0xFF24C6DC),
              title: const Text(
                'Are you sure?',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: const Text(
                'Are you sure you want to go back?',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              actions: [
                TextButton(
                  child: const Text(
                    'No',
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(false); // Block back
                  },
                ),
                TextButton(
                  child: const Text(
                    'Yes',
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                  onPressed: () {
                    FlameAudio.play('back_navigation.mp3', volume: 1);
                    Navigator.of(context).pop(true); // Allow back
                  },
                ),
              ],
            );
          },
        );
        return shouldExit == true;
      },
      child: OrientationBuilder(
        builder: (context, orientation) {
          final size = MediaQuery.of(context).size;
          final gameWidth = size.width;
          final gameHeight = size.height;

          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        backgroundColor: Color(0xFF24C6DC),
                        title: Text(
                          'Are you sure?',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        content: Text(
                          'Are you sure you want to go back?',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        actions: [
                          TextButton(
                            child: Text(
                              'No',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text(
                              'Yes',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              FlameAudio.play(
                                'back_navigation1.mp3',
                                volume: 1,
                              );
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
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
                highlightColor: const Color.fromARGB(255, 14, 17, 111),
                child: Text(
                  'CHOICE PUZZLE',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              centerTitle: true,
            ),
            body: Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: gameWidth,
                height: gameHeight,
                child: GameWidget(
                  game: game!,
                  overlayBuilderMap: {
                    'PuzzleCompleted': (context, game) {
                      WidgetsBinding.instance.addPostFrameCallback((_) async {
                        // FlameAudio.play('confetti3.mp3', volume: 1);
                        _player = await FlameAudio.play('confetti3.mp3');
                        _showCompletionDialog();
                        // _confettiController.play();
                        _updateProgress();
                      });
                      return Container();
                    },
                  },
                ),
              ),
            ),
            floatingActionButton: Listener(
              onPointerDown: (event) => _showReferenceImage(),
              onPointerUp: (event) => _hideReferenceImage(),
              child: Container(
                height: 55,
                width: 55,
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.image, color: Colors.white),
              ),
            ),
          );
        },
      ),
    );
  }
}
