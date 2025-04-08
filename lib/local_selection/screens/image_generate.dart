import 'dart:ui';

import 'package:choice_puzzle_app/controllers/category_controller.dart';
import 'package:choice_puzzle_app/controllers/progress_category_controller.dart';
import 'package:choice_puzzle_app/local_selection/constants/images_string.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class ImageGenerate extends StatefulWidget {
  final Map<String, List<String>> categorizedImages;
  final Map<String, int> completedPuzzles;
  final Map<String, dynamic> difficulty;
  final Function(int, Map<String, dynamic>, bool isReplay) loadAssetImage;

  const ImageGenerate({
    Key? key,
    required this.categorizedImages,
    required this.completedPuzzles,
    required this.difficulty,
    required this.loadAssetImage,
  }) : super(key: key);

  @override
  State<ImageGenerate> createState() => _ImageGenerateState();
}

class _ImageGenerateState extends State<ImageGenerate> {
  final CategoryController categoryController = Get.put(CategoryController());
  final PuzzleProgressController puzzleProgressController = Get.put(
    PuzzleProgressController(),
  );
  @override
  void initState() {
    super.initState();
    // _confettiController.play();
    _loadCompletedPuzzles();
  }

  void _loadCompletedPuzzles() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      widget.completedPuzzles.forEach((key, _) {
        widget.completedPuzzles[key] = prefs.getInt(key) ?? 0;
      });
    });
  }

  List<String> getFilteredImages() {
    return widget.categorizedImages[categoryController
            .selectedCategory
            .value] ??
        [];
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

  @override
  void dispose() {
    // _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String selectedCategory = categoryController.selectedCategory.value;
    String key =
        'completed_${selectedCategory}_${widget.difficulty['rows']}x${widget.difficulty['cols']}';
    return Obx(() {
      int completedIndex = puzzleProgressController.completedPuzzles[key] ?? 0;
      List<String> filteredImages =
          getFilteredImages(); // Get images for selected category
      return Scaffold(
        appBar: AppBar(
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
            highlightColor: const Color.fromARGB(255, 14, 17, 111),
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
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1D2B64), Color(0xFFF8CDDA)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 20),
                Container(
                  width: 350,
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFa8edea), Color(0xFFfed6e3)],
                    ),
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.black,
                      style: BorderStyle.solid,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: DropdownButton<String>(
                      underline: Container(),
                      enableFeedback: true,
                      borderRadius: BorderRadius.circular(20),
                      dropdownColor: const Color(0xFFa8edea),
                      value: categoryController.selectedCategory.value,
                      focusNode: FocusNode(
                        descendantsAreFocusable: true,
                        descendantsAreTraversable: true,
                      ),
                      icon: const Icon(Icons.arrow_drop_down),
                      isExpanded: true,
                      autofocus: false,
                      alignment: AlignmentDirectional.bottomEnd,
                      focusColor: Colors.black,
                      items:
                          widget.categorizedImages.keys.map((String category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(
                                category,
                                style: TextStyle(color: Colors.black),
                              ),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        FlameAudio.play('category_tap.mp3',volume: 1);
                        setState(() {
                          categoryController.selectedCategory.value = newValue!;
                          print(
                            'Selected Filter: $categoryController',
                          ); // Debug log
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: 10),
                // Displaying the images based on selected category
                Container(
                  child: KeyedSubtree(
                    key: ValueKey(categoryController.selectedCategory.value),
                    child: GridView.builder(
                      padding: EdgeInsets.all(12),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: .8,
                          ),
                      itemCount: filteredImages.length, // Count filtered images
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        bool isUnlocked = index == 0 || index <= completedIndex;
                        return Animate(
                          effects: [
                            SlideEffect(
                              begin: Offset(0, 1), // Start from bottom
                              end: Offset(0, 0),
                              curve: Curves.easeOutBack,
                              duration: 1100.ms,
                              delay: Duration(
                                milliseconds: 300,
                              ), // staggered animation
                            ),
                            FadeEffect(duration: 1100.ms),
                          ],
                          child: GestureDetector(
                            onTap: () async {
                              if (!isUnlocked) {
                                FlameAudio.play('lock.mp3',volume: 1);
                                bool hasShownSnackbar = false;
                                if (!hasShownSnackbar) {
                                  Get.snackbar(
                                    backgroundGradient: LinearGradient(
                                      colors: [
                                        Color(0xFFa8edea),
                                        Color(0xFFfed6e3),
                                      ],
                                    ),
                                    snackStyle: SnackStyle.FLOATING,
                                    snackPosition: SnackPosition.BOTTOM,
                                    snackbarStatus: (status) {
                                      if (status == SnackbarStatus.CLOSED) {
                                        hasShownSnackbar = true;
                                      }
                                    },
                                    isDismissible: true,
                                    backgroundColor: Colors.white,
                                    margin: EdgeInsets.only(
                                      right: 10,
                                      left: 10,
                                      bottom: 3,
                                    ),
                                    '',
                                    '',
                                    titleText: Text(
                                      'Locked',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                    messageText: Text(
                                      'Solved the previous puzzle first!',
                                      style: TextStyle(fontSize: 15),
                                    ),
                                    // duration: Duration(milliseconds: 1700),
                                  );
                                }
                                return;
                              }
                              bool isFirstTimePlay = index == completedIndex;

                              if (isFirstTimePlay) {
                                widget.loadAssetImage(
                                  index,
                                  widget.difficulty,
                                  false,
                                ); // isReplay false by default
                              } else {
                                bool? tryAgain = await Get.dialog<bool>(
                                  AlertDialog(
                                    backgroundColor: Color(0xFFa8edea),
                                    title: Text(
                                      "Already Solved",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    content: Text("Do you want to Play again?"),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Get.back(result: false),
                                        child: Text(
                                          "Cancel",
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () => Get.back(result: true),
                                        child: Text(
                                          "Play Again",
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ),
                                    ],
                                  ),
                                );

                                if (tryAgain == true) {
                                  widget.loadAssetImage(
                                    index,
                                    widget.difficulty,
                                    true,
                                  ); // 👈 Add this param
                                }
                              }
                            },
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.asset(
                                        filteredImages[index],
                                        fit: BoxFit.cover,
                                      ),
                                      if (!isUnlocked)
                                        Positioned.fill(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                            child: BackdropFilter(
                                              filter: ImageFilter.blur(
                                                sigmaX: 5,
                                                sigmaY: 5,
                                              ),
                                              child: Container(
                                                color: Colors.white.withOpacity(
                                                  0.1,
                                                ), // frosted look
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                // Lock icon overlay
                                // if (!isUnlocked)
                                Positioned.fill(
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: AnimatedSwitcher(
                                      // switchInCurve: Curves.bounceIn,
                                      // switchOutCurve: Curves.easeOut,
                                      key: ValueKey('locked'),
                                      duration: const Duration(
                                        milliseconds: 2500,
                                      ),
                                      transitionBuilder:
                                          (child, animation) => ScaleTransition(
                                            scale: animation,
                                            child: child,
                                          ),
                                      child:
                                          isUnlocked
                                              ? SizedBox(
                                                key: ValueKey(
                                                  "unlocked_$index",
                                                ),
                                              )
                                              : // no icon
                                              // : Container(
                                              //   key: ValueKey(
                                              //     "locked_$index",
                                              //   ), // 👈 Key must change
                                              //   width: 100,
                                              //   height: 100,
                                              //   decoration: BoxDecoration(
                                              //     color: const Color.fromARGB(
                                              //       107,
                                              //       0,
                                              //       0,
                                              //       0,
                                              //     ),
                                              //     shape: BoxShape.circle,
                                              //   ),
                                              //   child: const
                                              Icon(
                                                Icons.lock_outline_rounded,
                                                size: 90,
                                                color: Colors.white,
                                              ),
                                      // ),
                                    ),
                                  ),
                                ),
                              ],
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
    });
  }
}
