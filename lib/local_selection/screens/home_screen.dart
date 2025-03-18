import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'puzzle_game_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();

  // Define difficulty options as rows and columns.
  final List<Map<String, int>> difficulties = [
    {'rows': 2, 'cols': 2},  // 4 pieces (2x2)
    {'rows': 4, 'cols': 4},  // 16 pieces (4x4)
    {'rows': 4, 'cols': 5},  // 20 pieces (4x5)
    {'rows': 5, 'cols': 6},  // 30 pieces (5x6)
  ];

  int selectedDifficultyIndex = 0; // Default: 4 pieces

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // For web support, use readAsBytes() from the XFile.
      final bytes = await pickedFile.readAsBytes();
      final selectedDifficulty = difficulties[selectedDifficultyIndex];
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PuzzleGameScreen(
            imageBytes: bytes,
            rows: selectedDifficulty['rows']!,
            cols: selectedDifficulty['cols']!,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Choice Puzzle game"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton<int>(
              value: selectedDifficultyIndex,
              items: [
                DropdownMenuItem(child: Text("4 pieces (2x2)"), value: 0),
                DropdownMenuItem(child: Text("16 pieces (4x4)"), value: 1),
                DropdownMenuItem(child: Text("20 pieces (4x5)"), value: 2),
                DropdownMenuItem(child: Text("30 pieces (5x6)"), value: 3),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedDifficultyIndex = value;
                  });
                }
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text("Pick an Image"),
            ),
          ],
        ),
      ),backgroundColor: Colors.white,
    );
  }
}
