import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../game/puzzle_piece.dart';
import 'puzzle_game_screen.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  int completedPuzzles = 0;
  final int requiredPuzzles = 10;

  final List<Map<String, int>> difficulties = [
    {'rows': 2, 'cols': 2},
    {'rows': 4, 'cols': 4},
    {'rows': 4, 'cols': 5},
    {'rows': 5, 'cols': 6},
  ];

  final List<String> difficultyNames = [
    '2x2\nPuzzle',
    '4x4\nPuzzle',
    '4x5\nPuzzle',
    '5x6\nPuzzle',
  ];

  int selectedDifficultyIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      completedPuzzles = prefs.getInt('completed2x2') ?? 0;
    });
  }

  Future<void> _updateProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      completedPuzzles++;
    });
    prefs.setInt('completed2x2', completedPuzzles);
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // Stop music when screen is closed
    super.dispose();
  }

  Future<void> _playBackgroundMusic() async {
    await _audioPlayer.play(
      AssetSource('music/Mr_Smith-Azul.mp3'),
    ); // Play loop
    _audioPlayer.setReleaseMode(ReleaseMode.loop); // Loop music
  }

  Future<void> _stopMusic() async {
    await _audioPlayer.stop(); // Stop music if needed
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Puzzle Completed!"),
            content: Text("Congratulations! You've completed the puzzle."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              ),
            ],
          ),
    );
  }

  Future<void> _pickImage(int index) async {
    if (index > 0 && completedPuzzles < requiredPuzzles) {
      _showLockedDialog();
      return;
    }
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      final selectedDifficulty = difficulties[selectedDifficultyIndex];
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => PuzzleGameScreen(
                imageBytes: bytes,
                rows: selectedDifficulty['rows']!,
                cols: selectedDifficulty['cols']!,
                onPuzzleCompleted: _updateProgress,
              ),
        ),
      );
    }
  }

  void _showLockedDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Level Locked"),
            content: Text(
              "Solve the 2x2 puzzle $requiredPuzzles times to unlock this level.\n\n"
              "Progress: $completedPuzzles/$requiredPuzzles",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            isPlaying ? Icons.music_note : Icons.music_off,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              isPlaying = !isPlaying;
            });
            isPlaying ? _playBackgroundMusic() : _stopMusic();
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF24C6DC), Color(0xFF514A9D)],
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
              fontSize: 26,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1D2B64), Color(0xFFF8CDDA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: .7,
                ),
                itemCount: difficultyNames.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  bool isLocked =
                      index > 0 && completedPuzzles < requiredPuzzles;
                  return GestureDetector(
                    onTap: () async {
                      _pickImage(index);
                      // final pickedFile = await _picker.pickImage(
                      //   source: ImageSource.gallery,
                      // );
                      // if (pickedFile != null) {
                      //   final bytes = await pickedFile.readAsBytes();
                      //   final selectedDifficulty =
                      //       difficulties[index]; // 👈 Select difficulty from list

                      //   Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //       builder:
                      //           (context) => PuzzleGameScreen(
                      //             imageBytes: bytes,
                      //             rows: selectedDifficulty['rows']!,
                      //             cols: selectedDifficulty['cols']!,
                      //           ),
                      //     ),
                      //   );
                      // }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isLocked ? Colors.grey : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          difficultyNames[index],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
