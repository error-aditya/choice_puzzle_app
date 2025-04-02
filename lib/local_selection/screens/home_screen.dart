// import 'dart:typed_data';

// import 'package:audioplayers/audioplayers.dart';
// import 'package:choice_puzzle_app/local_selection/dashboard/dashboard_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../game/puzzle_piece.dart';
// import 'puzzle_game_screen.dart';
// import 'package:shimmer/shimmer.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:get/get.dart';

// class HomeScreen extends StatefulWidget {
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   int completedPuzzles = 0;
//   final int requiredPuzzles = 100;

//   final List<Map<String, int>> difficulties = [
//     {'rows': 2, 'cols': 2},
//     {'rows': 4, 'cols': 4},
//     {'rows': 5, 'cols': 5},
//     {'rows': 6, 'cols': 6},
//     {'rows': 7, 'cols': 7},
//     {'rows': 8, 'cols': 8},
//     {'rows': 9, 'cols': 9},
//     {'rows': 10, 'cols': 10},
//     {'rows': 11, 'cols': 11},
//     // {'rows': 0, 'cols': 0},
//   ];

//   final List<String> assetImages = [
//     'assets/puzzle_images/image_categories/cartoon/doraemon.svg',
//     'assets/puzzle_images/image_categories/anime_images/pirate_flag.jpg',
//     'assets/puzzle_images/image_categories/vehicles/car.jpg',
//     'assets/puzzle_images/image_categories/anime_images/luffy_gear5.jpg',
//     'assets/puzzle_images/image_categories/animals/dressed_cat.jpg',
//     'assets/puzzle_images/image_categories/cartoon/super_mario.png',
//     'assets/puzzle_images/image_categories/person/eye.jpg',
//     'assets/puzzle_images/image_categories/anime_images/strawhats.jpg',
//     'assets/puzzle_images/image_categories/anime_images/luffy.jpg',
//     'assets/puzzle_images/image_categories/illusion/illusion_2.jpg',
//     'assets/puzzle_images/image_categories/cartoon/fox.jpg',
//     'assets/puzzle_images/image_categories/monuments/minar.jpg',
//     'assets/puzzle_images/image_categories/natural/mountain.jpg',
//     'assets/puzzle_images/image_categories/animals/puppies.jpg',
//     'assets/puzzle_images/image_categories/anime_images/luffy.jpg',
//     'assets/puzzle_images/image_categories/illusion/illusion_3.jpg',
//     'assets/puzzle_images/image_categories/cartoon/motu_patlu.jpg',
//     'assets/puzzle_images/image_categories/natural/space_earth_photo.jpg',
//     'assets/puzzle_images/image_categories/natural/sunset_bird.jpg',
//     'assets/puzzle_images/image_categories/animals/tiger.jpg',
//     'assets/puzzle_images/image_categories/natural/trees_1.jpg',
//     'assets/puzzle_images/image_categories/illusion/illusion_1.jpg',
//     'assets/puzzle_images/image_categories/anime_images/timeskip_with_sunny.jpg',
//     'assets/puzzle_images/image_categories/anime_images/naruto.svg',
//   ];

//   // final List<String> difficultyNames = [
//   //   '2x2\nPuzzle',
//   //   '4x4\nPuzzle',
//   //   '5x5\nPuzzle',
//   //   '6x6\nPuzzle',
//   //   '7x7\nPuzzle',
//   //   '8x8\nPuzzle',
//   //   '9x9\nPuzzle',
//   //   '10x10\nPuzzle',
//   //   'Easy',
//   //   'Choice Puzzle',
//   // ];

//   Future<void> _loadAssetImage(int index, Map<String, int> difficulty) async {
//     int userRows = difficulty['rows']!;
//     int userCols = difficulty['cols']!;

//     // Load image bytes from assets
//     ByteData data = await rootBundle.load(assetImages[index]);
//     Uint8List bytes = data.buffer.asUint8List();

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder:
//             (context) => PuzzleGameScreen(
//               imageBytes: bytes,
//               rows: userRows,
//               cols: userCols,
//               onPuzzleCompleted: () => _updateProgress(),
//             ),
//       ),
//     );
//   }

//   _showDifficultySelectionDialog(int imageIndex) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return Dialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           backgroundColor: Colors.transparent,
//           child: Stack(
//             alignment: Alignment.center,
//             children: [
//               Container(
//                 padding: EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [Color(0xFF1D2B64), Color(0xFFF8CDDA)],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   borderRadius: BorderRadius.circular(20),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.5),
//                       blurRadius: 10,
//                       offset: Offset(0, 5),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       "Choose difficulty level",
//                       style: GoogleFonts.poppins(
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                     SizedBox(height: 15),
//                     Column(
//                       children:
//                           difficulties.map((difficulty) {
//                             String difficultyText =
//                                 "${difficulty['rows']} x ${difficulty['cols']} Puzzle";

//                             return Padding(
//                               padding: const EdgeInsets.symmetric(vertical: 5),
//                               child: ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: const Color.fromARGB(
//                                     255,
//                                     34,
//                                     73,
//                                     201,
//                                   ),
//                                   padding: EdgeInsets.symmetric(
//                                     vertical: 12,
//                                     horizontal: 10,
//                                   ),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                 ),
//                                 onPressed: () async {
//                                   Navigator.pop(context);
//                                   _loadAssetImage(imageIndex, difficulty);
//                                 },
//                                 child: Text(
//                                   difficultyText,
//                                   style: TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                               ),
//                             );
//                           }).toList(),
//                     ),
//                     SizedBox(height: 10),
//                     TextButton(
//                       onPressed: () => Navigator.pop(context),
//                       child: Text(
//                         "Cancel",
//                         style: TextStyle(
//                           color: const Color.fromARGB(255, 23, 46, 136),
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   int selectedDifficultyIndex = 0;

//   @override
//   void initState() {
//     super.initState();
//     _loadProgress();
//   }

//   @override
//   void dispose() {
//     _updateProgress();
//     super.dispose();
//   }

//   Future<void> _loadProgress() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       completedPuzzles = prefs.getInt('completed2x2') ?? 0;
//     });
//     print("Loaded completedPuzzles: $completedPuzzles"); // Debugging log
//   }

//   Future<void> _updateProgress() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setInt('completed2x2', completedPuzzles);
//     print("Updated completedPuzzles: $completedPuzzles"); // Debug log
//     if (completedPuzzles >= requiredPuzzles) {
//       await prefs.setBool('allUnlocked', true);
//     }
//   }

//   // Future<void> _pickImage(int index) async {
//   //   final prefs = await SharedPreferences.getInstance();
//   //   bool allUnlocked = prefs.getBool('allUnlocked') ?? false;

//   //   if (index < difficulties.length - 1 &&
//   //       index > 0 &&
//   //       !allUnlocked &&
//   //       index > 0 &&
//   //       completedPuzzles < requiredPuzzles) {
//   //     _showLockedDialog();
//   //     return;
//   //   }

//   //   int? userRows;
//   //   int? userCols;

//   //   // if (index == difficultyNames.length - 1) {
//   //   //   // If "Choice Puzzle" is selected
//   //   //   final customSize = await _showCustomSizeDialog();
//   //   //   if (customSize == null) return;
//   //   //   userRows = customSize['rows'];
//   //   //   userCols = customSize['cols'];
//   //   // } else {
//   //   //   userRows = difficulties[index]['rows'];
//   //   //   userCols = difficulties[index]['cols'];
//   //   // }

//   //   final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//   //   if (pickedFile != null) {
//   //     final bytes = await pickedFile.readAsBytes();
//   //     Navigator.push(
//   //       context,
//   //       MaterialPageRoute(
//   //         builder:
//   //             (context) => PuzzleGameScreen(
//   //               imageBytes: bytes,
//   //               rows: userRows!,
//   //               cols: userCols!,
//   //               onPuzzleCompleted: () => _updateProgress(),
//   //             ),
//   //       ),
//   //     );
//   //   }
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFF1D2B64), Color(0xFFF8CDDA)],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: Center(
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 GridView.builder(
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 2,
//                     crossAxisSpacing: 10,
//                     mainAxisSpacing: 10,
//                     childAspectRatio: .8,
//                   ),
//                   addRepaintBoundaries: true,
//                   itemCount: assetImages.length,
//                   shrinkWrap: true,
//                   physics: NeverScrollableScrollPhysics(),
//                   itemBuilder: (context, index) {
//                     bool isLocked =
//                         index > 0 && completedPuzzles < requiredPuzzles;
//                     return GestureDetector(
//                       onTap: () async {
//                         if (index < assetImages.length) {
//                           await _showDifficultySelectionDialog(index);
//                         }
//                         // final pickedFile = await _picker.pickImage(
//                         //   source: ImageSource.gallery,
//                         // );
//                         // if (pickedFile != null) {
//                         //   final bytes = await pickedFile.readAsBytes();
//                         //   final selectedDifficulty =
//                         //       difficulties[index]; // Select difficulty from list
//                         //   Navigator.push(
//                         //     context,
//                         //     MaterialPageRoute(
//                         //       builder:
//                         //           (context) => PuzzleGameScreen(
//                         //             imageBytes: bytes,
//                         //             rows: selectedDifficulty['rows']!,
//                         //             cols: selectedDifficulty['cols']!,
//                         //           ),
//                         //     ),
//                         //   );
//                         // }
//                       },
//                       child: Container(
//                         decoration: BoxDecoration(
//                           border: Border.all(color: Colors.black),
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(20),
//                           child: Image(
//                             image: AssetImage(assetImages[index]),
//                             fit: BoxFit.fill,
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
