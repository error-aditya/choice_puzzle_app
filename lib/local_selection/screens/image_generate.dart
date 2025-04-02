import 'package:choice_puzzle_app/controllers/category_controller.dart';
import 'package:choice_puzzle_app/controllers/progress_category_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class ImageGenerate extends StatefulWidget {
  final Map<String, List<String>> categorizedImages;
  final Map<String, int> completedPuzzles;
  final Map<String, dynamic> difficulty;
  final Function(int, Map<String, dynamic>) loadAssetImage;

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
    _loadCompletedPuzzles();
  }

  void _loadCompletedPuzzles() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      widget.completedPuzzles.forEach((key, _) {
        widget.completedPuzzles[key] = prefs.getInt(key) ?? 0;
      });
    });

    print("Loaded completed puzzles: ${widget.completedPuzzles}");
  }

  List<String> getFilteredImages() {
    return widget.categorizedImages[categoryController
            .selectedCategory
            .value] ??
        [];
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
                // DropdownButton for selecting the category
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
                      borderRadius: BorderRadius.circular(20),
                      dropdownColor: const Color(0xFFa8edea),
                      value: categoryController.selectedCategory.value,
                      focusNode: FocusNode(
                        // canRequestFocus: true,
                        descendantsAreFocusable: true,descendantsAreTraversable: true
                      ),
                      icon: const Icon(Icons.arrow_drop_down),
                      isExpanded: true,
                      autofocus: false,
                      alignment: AlignmentDirectional.bottomEnd,
                      // isDense: true,
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
                  child: GridView.builder(
                    padding: EdgeInsets.all(5),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.0,
                        ),
                    itemCount: filteredImages.length, // Count filtered images
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      bool isUnlocked = index <= completedIndex;
                      return GestureDetector(
                        onTap: () async {
                          if (isUnlocked) {
                            widget.loadAssetImage(
                              index,
                              widget.difficulty,
                            ); // Load the selected image
                          }
                        },
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.asset(
                                filteredImages[index], // Display image from selected category
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
                              const Positioned.fill(
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
