import 'package:audioplayers/audioplayers.dart';
import 'package:choice_puzzle_app/controllers/category_controller.dart';
import 'package:choice_puzzle_app/local_selection/constants/images_string.dart';
import 'package:choice_puzzle_app/local_selection/screens/image_generate.dart';
import 'package:choice_puzzle_app/local_selection/screens/puzzle_game_screen.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
// import 'package:animate_do/animate_do.dart';

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
  final _picker = ImagePicker();

  bool isPlaying = false;

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

  Future<void> _pickImage(int index) async {
    final prefs = await SharedPreferences.getInstance();
    bool allUnlocked = prefs.getBool('allUnlocked') ?? false;

    if (index < difficulties.length - 1 &&
        index > 0 &&
        !allUnlocked &&
        index > 0 &&
        completedPuzzles[difficulties[index]['name']]! < requiredPuzzles) {
      // _showLockedDialog();
      return;
    }

    int? userRows;
    int? userCols;

    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => PuzzleGameScreen(
                imageBytes: bytes,
                rows: userRows!,
                cols: userCols!,
                onPuzzleCompleted:
                    () => _updateProgress(categorizedImages.keys.first),
                category: '',
              ),
        ),
      );
    }
  }

  Future<void> _loadAssetImage(
    int index,
    Map<String, dynamic> difficulty, {
    bool isReplay = false,
  }) async {
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
                isReplay: isReplay,
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
    // print("Loaded completedPuzzles: $completedPuzzles"); // Debug log
  }

  Future<void> _updateProgress(String category) async {
    final prefs = await SharedPreferences.getInstance();
    int updatedProgress = (prefs.getInt('progress_$category') ?? 0) + 1;
    await prefs.setInt('progress_$category', updatedProgress);

    setState(() {
      completedPuzzles[category] = updatedProgress;
    });
    print(
      "Updated progress: $updatedProgress for ${difficulties[selectedDifficultyIndex]['rows']}x${difficulties[selectedDifficultyIndex]['cols']}",
    );
  }

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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        // actions: [
        //   IconButton(
        //     icon: Icon(
        //       isPlaying ? Icons.music_note : Icons.music_off,
        //       color: Colors.white,
        //     ),
        //     onPressed: () {
        //       setState(() {
        //         isPlaying = !isPlaying;
        //       });
        //       isPlaying ? _playBackgroundMusic() : _stopMusic();
        //     },
        //   ),
        // ],
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF24C6DC), Color(0xFF514A9D)],
              // colors: [Color(0xFF30cfd0), Color(0xFF330867)],
              // colors: [
              //   Color.fromARGB(255, 118, 74, 22),
              //   Color.fromARGB(255, 194, 148, 22),
              // ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // SizedBox(width: 40),
            Shimmer.fromColors(
              baseColor: Color.fromARGB(255, 0, 0, 0),
              direction: ShimmerDirection.rtl,
              highlightColor: const Color.fromARGB(255, 255, 255, 255),
              child: Text(
                'CHOICE',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            SizedBox(width: 5),
            Image.asset('assets/logo/icon.png', height: 50),
            SizedBox(width: 5),
            Shimmer.fromColors(
              baseColor: Color.fromARGB(255, 0, 0, 0),
              direction: ShimmerDirection.rtl,
              highlightColor: const Color.fromARGB(255, 255, 255, 255),
              child: Text(
                'PUZZLE',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF24C6DC), Color(0xFF514A9)],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: .8,
                        ),
                    itemCount: difficultyNames.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          FlameAudio.play('entry_to_selecting_image.mp3', volume: 1);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ImageGenerate(
                                    categorizedImages: categorizedImages,
                                    completedPuzzles: completedPuzzles,
                                    difficulty: difficulties[index],
                                    loadAssetImage: (
                                      int imageIndex,
                                      Map<String, dynamic> diff, [
                                      bool isReplay = false,
                                    ]) {
                                      return _loadAssetImage(
                                        imageIndex,
                                        diff,
                                        isReplay: isReplay,
                                      );
                                    },
                                  ),
                            ),
                          );
                        },
                        child: Animate(
                          effects: [
                            ScaleEffect(
                              duration: 600.ms,
                              begin: Offset(0.95, 0.95),
                              end: Offset(1, 1),
                            ),
                            FadeEffect(duration: 600.ms),
                          ],
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF0f0c29),
                                  Color(0xFF302b63),
                                  Color(0xFF24243e),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blueAccent.withOpacity(0.4),
                                  blurRadius: 15,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                Center(
                                  child: GlowText(
                                    textAlign: TextAlign.center,
                                    difficultyNames[index],
                                    style: GoogleFonts.orbitron(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                    glowColor: Colors.cyanAccent,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 12.0,
                                    ),
                                    child: Icon(
                                          Icons.play_circle_fill_rounded,
                                          size: 40,
                                          color: Colors.white.withOpacity(0.8),
                                        )
                                        .animate(
                                          onPlay:
                                              (controller) => controller.repeat(
                                                reverse: true,
                                              ),
                                        )
                                        .scaleXY(
                                          begin: 1.0,
                                          end: 1.1,
                                          duration: 700.ms,
                                          curve: Curves.easeInOut,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
