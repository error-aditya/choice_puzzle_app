import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:choice_puzzle_app/controllers/category_controller.dart';
// import 'package:choice_puzzle_app/local_selection/dashboard/dashboard_screen.dart';
import 'package:choice_puzzle_app/local_selection/screens/image_generate.dart';
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
  // String? selectedCategory;
  final CategoryController categoryController = Get.put(CategoryController());

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

  final Map<String, List<String>> categorizedImages = {
    'Animals': [
      'assets/puzzle_images/image_categories/animals/blackbuck.jpg',
      'assets/puzzle_images/image_categories/animals/elephant.jpg',
      'assets/puzzle_images/image_categories/animals/cat.jpg',
      'assets/puzzle_images/image_categories/animals/dressed_cat.jpg',
      'assets/puzzle_images/image_categories/animals/eagle.jpg',
      'assets/puzzle_images/image_categories/animals/frog.jpg',
      'assets/puzzle_images/image_categories/animals/horses.jpg',
      'assets/puzzle_images/image_categories/animals/ostrich.jpg',
      'assets/puzzle_images/image_categories/animals/parrot.jpg',
      'assets/puzzle_images/image_categories/animals/peacock.jpg',
      'assets/puzzle_images/image_categories/animals/puppies.jpg',
      'assets/puzzle_images/image_categories/animals/tiger.jpg',
    ],
    'Anime': [
      'assets/puzzle_images/image_categories/anime_images/pirate_flag.jpg',
      'assets/puzzle_images/image_categories/anime_images/luffy.jpg',
      'assets/puzzle_images/image_categories/anime_images/nezuko_chan.jpg',
      'assets/puzzle_images/image_categories/anime_images/timeskip_with_sunny.jpg',
      'assets/puzzle_images/image_categories/anime_images/strawhats.jpg',
      'assets/puzzle_images/image_categories/anime_images/naruto.svg',
      'assets/puzzle_images/image_categories/anime_images/luffy_gear5.jpg',
    ],
    'Cartoon': [
      'assets/puzzle_images/image_categories/cartoon/bal_ganesh.jpg',
      'assets/puzzle_images/image_categories/cartoon/mickey_mouse.jpg',
      'assets/puzzle_images/image_categories/cartoon/doraemon.svg',
      'assets/puzzle_images/image_categories/cartoon/tom_and_jerry.jpg',
      'assets/puzzle_images/image_categories/cartoon/sinchan.jpg',
      'assets/puzzle_images/image_categories/cartoon/minions.jpg',
      'assets/puzzle_images/image_categories/cartoon/krishna.jpg',
      'assets/puzzle_images/image_categories/cartoon/motu_patlu.jpg',
      'assets/puzzle_images/image_categories/cartoon/oggy_and_cockroaches.jpg',
      'assets/puzzle_images/image_categories/cartoon/spiderman.jpg',
      'assets/puzzle_images/image_categories/cartoon/super_mario.png',
      'assets/puzzle_images/image_categories/cartoon/fox.jpg',
    ],
    'Illusion': [
      'assets/puzzle_images/image_categories/illusion/board_illusion.jpg',
      'assets/puzzle_images/image_categories/illusion/spinning_illusion.jpg',
      'assets/puzzle_images/image_categories/illusion/ladder_illusion.jpg',
      'assets/puzzle_images/image_categories/illusion/illusion_1.jpg',
      'assets/puzzle_images/image_categories/illusion/holi_colors_illusion.jpg',
      'assets/puzzle_images/image_categories/illusion/greek_abstraction_illusion.jpg',
      'assets/puzzle_images/image_categories/illusion/illusion_2.jpg',
      'assets/puzzle_images/image_categories/illusion/zebra_illusion.jpg',
      'assets/puzzle_images/image_categories/illusion/color_illusion.jpg',
      'assets/puzzle_images/image_categories/illusion/chain_illusion.jpg',
      'assets/puzzle_images/image_categories/illusion/illusion_3.jpg',
      'assets/puzzle_images/image_categories/illusion/square_illusion.jpg',
    ],
    'Natural': [
      'assets/puzzle_images/image_categories/natural/himalayas.jpg',
      'assets/puzzle_images/image_categories/natural/morpunkh.jpg',
      'assets/puzzle_images/image_categories/natural/mountain.jpg',
      'assets/puzzle_images/image_categories/natural/pink_roses.jpg',
      'assets/puzzle_images/image_categories/natural/railway_line.jpg',
      'assets/puzzle_images/image_categories/natural/space_earth_photo.jpg',
      'assets/puzzle_images/image_categories/natural/sunset_bird.jpg',
      'assets/puzzle_images/image_categories/natural/sunset.jpg',
      'assets/puzzle_images/image_categories/natural/trees_1.jpg',
      'assets/puzzle_images/image_categories/natural/walking_bridge.jpg',
      'assets/puzzle_images/image_categories/natural/water_drop.jpg',
      'assets/puzzle_images/image_categories/natural/waterfall.jpg',
    ],
    'Monuments': [
      'assets/puzzle_images/image_categories/monuments/christ_the_redeemer.jpg',
      'assets/puzzle_images/image_categories/monuments/eiffel_tower.jpg',
      'assets/puzzle_images/image_categories/monuments/giza_pyramid.jpg',
      'assets/puzzle_images/image_categories/monuments/red_fort.jpg',
      'assets/puzzle_images/image_categories/monuments/taj_mahal.jpg',
      'assets/puzzle_images/image_categories/monuments/statue_of_unity.jpg',
      'assets/puzzle_images/image_categories/monuments/colosseum.jpg',
      'assets/puzzle_images/image_categories/monuments/minar.jpg',
    ],
    'Person': ['assets/puzzle_images/image_categories/person/eye.jpg'],
    'Vehicles': ['assets/puzzle_images/image_categories/vehicles/car.jpg'],
    'Fictional' : [
      'assets/puzzle_images/image_categories/fictional/fictional_1.jpg',
      'assets/puzzle_images/image_categories/fictional/fictional_2.jpg',
      'assets/puzzle_images/image_categories/fictional/fictional_3.jpg',
      'assets/puzzle_images/image_categories/fictional/fictional_4.jpg',
      'assets/puzzle_images/image_categories/fictional/fictional_5.jpg',
      'assets/puzzle_images/image_categories/fictional/fictional_6.jpg',
      'assets/puzzle_images/image_categories/fictional/fictional_7.jpg',
      'assets/puzzle_images/image_categories/fictional/fictional_8.jpg',
      'assets/puzzle_images/image_categories/fictional/fictional_9.jpg',
      'assets/puzzle_images/image_categories/fictional/fictional_10.jpg',
      'assets/puzzle_images/image_categories/fictional/fictional_11.jpg',
      'assets/puzzle_images/image_categories/fictional/fictional_12.jpg',
    ],
  };

  final List<String> difficultyNames = [
    '4 pieces',
    '16 pieces',
    '25 pieces',
    '36 pieces',
    '49 pieces',
    '64 pieces',
    '81 pieces',
    '100 pieces',
    //'0x0\nPuzzle',
  ];

  final Map<String, int> categoryProgress = {
    'Animals': 0,
    'Anime': 0,
    'Cartoon': 0,
    'Illusion': 0,
    'Natural': 0,
    'Monuments': 0,
    'Person': 0,
    'Vehicles': 0,
  };

  int selectedDifficultyIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  @override
  void dispose() {
    _updateProgress(categorizedImages.keys.first);
    super.dispose();
  }

  Future<void> _loadAssetImage(
    int index,
    Map<String, dynamic> difficulty,
  ) async {
    if (categoryController.selectedCategory.value == null) {
      print('Error: No category selected.');
      return;
    }

    String selectedCategories = categoryController.selectedCategory.value;

    int userRows = difficulty['rows']!;
    int userCols = difficulty['cols']!;

    if (!categorizedImages.containsKey(selectedCategories)) {
      print(
        'Error: Selected filter "$selectedCategories" is not found in categories.',
      );
      return;
    }

    List<String> images = categorizedImages[selectedCategories] ?? [];

    if (images.isEmpty) {
      print('Error: No images found in the selected category.');
      return;
    }

    if (index < 0 || index >= images.length) {
      print(
        'Error: Index out of range. Index: $index, Available images: ${images.length}',
      );
      return;
    }

    String imagePath = images[index];

    try {
      ByteData data = await rootBundle.load(imagePath);
      Uint8List bytes = data.buffer.asUint8List();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => PuzzleGameScreen(
                category: selectedCategories,
                imageBytes: bytes,
                rows: userRows,
                cols: userCols,
                onPuzzleCompleted: () => _updateProgress(selectedCategories),
              ),
        ),
      );
    } catch (e) {
      print('Error loading image: $imagePath');
      print(e);
    }
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    // prefs.clear();
    setState(() {
      completedPuzzles = {}; // Reset before loading
      categoryProgress.forEach((category, progress) {
        completedPuzzles[category] = prefs.getInt('peogress_$category') ?? 0;
      });
      for (var diff in difficulties) {
        String key = 'completed${diff['rows']}x${diff['cols']}';
        completedPuzzles[key] = prefs.getInt(key) ?? 0;
      }
    });
    print("Loaded completedPuzzles: $completedPuzzles"); // Debug log
  }

  Future<void> _updateProgress(String category) async {
    final prefs = await SharedPreferences.getInstance();
    // String key = 'completed${difficulties[selectedDifficultyIndex]['rows']}x${difficulties[selectedDifficultyIndex]['cols']}';
    int updatedProgress = (prefs.getInt('progress_$category') ?? 0) + 1;
    await prefs.setInt('progress_$category', updatedProgress);

    setState(() {
      completedPuzzles[category] = updatedProgress;
    });
    print(
      "Updated progress: $updatedProgress for ${difficulties[selectedDifficultyIndex]['rows']}x${difficulties[selectedDifficultyIndex]['cols']}",
    );
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
                GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                      onTap: () {
                        if (categoryController.selectedCategory.value == null) {
                          print('Error: No category selected.');
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ImageGenerate(
                                  categorizedImages: categorizedImages,
                                  completedPuzzles: completedPuzzles,
                                  difficulty: difficulties[index],
                                  loadAssetImage: (
                                    int index,
                                    Map<String, dynamic> difficulty,
                                  ) {
                                    return _loadAssetImage(
                                      index,
                                      difficulty,
                                    ); // No need to specify category again
                                  },
                                ),
                          ),
                        );
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
                              color: Colors.black,
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
