import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:choice_puzzle_app/local_selection/dashboard/dashboard_screen.dart';
import 'package:choice_puzzle_app/local_selection/screens/puzzle_game_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../game/puzzle_piece.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

class PremiumScreen extends StatefulWidget {
  @override
  _PremiumScreenState createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  Map<String, int> completedPuzzles = {};
  final int requiredPuzzles = 100;
  bool showImages = false;
  bool isBack = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool isPlaying = false;

  final List<Map<String, int>> difficulties = [
    {'rows': 2, 'cols': 2},
    {'rows': 4, 'cols': 4},
    {'rows': 5, 'cols': 5},
    {'rows': 6, 'cols': 6},
    {'rows': 7, 'cols': 7},
    {'rows': 8, 'cols': 8},
    {'rows': 9, 'cols': 9},
    {'rows': 10, 'cols': 10},
    // {'rows': 0, 'cols': 0},
  ];

  final List<String> assetImages = [
    'assets/puzzle_images/doraemon.svg',
    'assets/puzzle_images/anime_images/pirate_flag.jpg',
    'assets/puzzle_images/car.jpg',
    'assets/puzzle_images/anime_images/luffy_gear5.jpg',
    'assets/puzzle_images/dressed_cat.jpg',
    'assets/puzzle_images/super_mario.png',
    'assets/puzzle_images/eye.jpg',
    'assets/puzzle_images/anime_images/strawhats.jpg',
    'assets/puzzle_images/anime_images/luffy.jpg',
    'assets/puzzle_images/illusion_2.jpg',
    'assets/puzzle_images/fox.jpg',
    'assets/puzzle_images/minar.jpg',
    'assets/puzzle_images/mountain.jpg',
    'assets/puzzle_images/puppies.jpg',
    'assets/puzzle_images/anime_images/luffy.jpg',
    'assets/puzzle_images/illusion_3.jpg',
    'assets/puzzle_images/motu_patlu.jpg',
    'assets/puzzle_images/space_earth_photo.jpg',
    'assets/puzzle_images/sunset_bird.jpg',
    'assets/puzzle_images/tiger.jpg',
    'assets/puzzle_images/trees_1.jpg',
    'assets/puzzle_images/illusion_1.jpg',
    'assets/puzzle_images/anime_images/timeskip_with_sunny.jpg',
    'assets/puzzle_images/anime_images/naruto.svg',
  ];

  final List<String> difficultyNames = [
    'Level 1\n4 pieces',
    'Level 2\n16 pieces',
    'Level 3\n25 pieces',
    'Level 4\n36 pieces',
    'Level 5\n49 pieces',
    'Level 6\n64 pieces',
    'Level 7\n81 pieces',
    'Level 8\n100 pieces',
    //'0x0\nPuzzle',
  ];

  int selectedDifficultyIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  @override
  void dispose() {
    _updateProgress();
    super.dispose();
  }

  Future<void> _loadAssetImage(int index, Map<String, int> difficulty) async {
    int userRows = difficulty['rows']!;
    int userCols = difficulty['cols']!;

    // Load image bytes from assets
    ByteData data = await rootBundle.load(assetImages[index]);
    Uint8List bytes = data.buffer.asUint8List();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => PuzzleGameScreen(
              imageBytes: bytes,
              rows: userRows,
              cols: userCols,
              onPuzzleCompleted: () => _updateProgress(),
            ),
      ),
    );
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    // prefs.clear();
    setState(() {
      completedPuzzles = {}; // Reset before loading
      for (var diff in difficulties) {
        String key = 'completed${diff['rows']}x${diff['cols']}';
        completedPuzzles[key] = prefs.getInt(key) ?? 0;
      }
    });
    print("Loaded completedPuzzles: $completedPuzzles"); // Debug log
  }

  Future<void> _updateProgress() async {
    final prefs = await SharedPreferences.getInstance();
    String key = 'completed${difficulty['rows']}x${difficulty['cols']}';
    int updatedProgress = (prefs.getInt(key) ?? 0) + 1;
    await prefs.setInt(key, updatedProgress);

    setState(() {
      completedPuzzles[key] = updatedProgress;
    });
    // print(
    //   "Updated progress for ${currentDifficulty['rows']}x${currentDifficulty['cols']}: $updatedProgress",
    // );
  }

  Map<String, int> difficulty = {'rows': 2, 'cols': 2};
  Future<void> _playBackgroundMusic() async {
    if (!isPlaying) return;
    await _audioPlayer.play(AssetSource('music/Mr_Smith-Azul.mp3'));
    _audioPlayer.setReleaseMode(ReleaseMode.loop); // Loop music
  }

  Future<void> _stopMusic() async {
    await _audioPlayer.stop(); // Stop music if needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon:
              showImages
                  ? Icon(Icons.arrow_back_ios, color: Colors.white)
                  : Icon(Icons.arrow_forward_ios, color: Colors.white),
          onPressed: () {
            setState(() {
              showImages = false;
            });
          },
        ),
        actions: [
          IconButton(
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
        ],
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
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 1000),
            curve: Curves.bounceInOut,
            alignment: showImages ? Alignment.centerLeft : Alignment.center,
            child: Text(
              'CHOICE PUZZLE',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1D2B64), Color(0xFFF8CDDA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 10),
                showImages
                    ? GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1.0,
                          ),
                      itemCount: assetImages.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        String key =
                            'completed${difficulty['rows']}x${difficulty['cols']}';
                        int completedIndex = completedPuzzles[key] ?? 0;
                        bool isUnlocked = index == 0 || index <= completedIndex;
                        return GestureDetector(
                          onTap: () async {
                            if (isUnlocked) {
                              _loadAssetImage(index, difficulty);
                            }
                          },
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.asset(
                                  assetImages[index],
                                  fit: BoxFit.cover,
                                  colorBlendMode:
                                      isUnlocked ? null : BlendMode.darken,
                                  color:
                                      isUnlocked
                                          ? null
                                          : const Color.fromARGB(131, 0, 0, 0),
                                ),
                              ),
                              if (!isUnlocked)
                                Positioned.fill(
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.lock,
                                      size: 50,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    )
                    : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.8,
                          ),
                      itemCount: difficultyNames.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () async {
                            setState(() {
                              difficulty = difficulties[index];
                              showImages = true;
                            });
                            // }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                colors: [
                                  Color.fromARGB(255, 56, 151, 224),
                                  Color.fromARGB(255, 31, 196, 214),
                                ],
                              ),
                              color: Colors.white,
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                difficultyNames[index],
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: index <= 2 ? Colors.black : index >= 2 && index <= 5? Colors.yellow : Colors.red,
                                ),
                                textAlign: TextAlign.center,
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
      ),
    );
  }
}
