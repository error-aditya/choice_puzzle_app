import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PuzzleProgressController extends GetxController {
  var completedPuzzles = <String, int>{}.obs; // Reactive map for completed puzzles

  @override
  void onInit() {
    super.onInit();
    loadCompletedPuzzles();
  }

  Future<void> loadCompletedPuzzles() async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, int> loadedData = {};

    // Load all stored completed puzzle progress
    prefs.getKeys().forEach((key) {
      if (key.startsWith('completed_')) {
        loadedData[key] = prefs.getInt(key) ?? 0;
      }
    });

    completedPuzzles.assignAll(loadedData);
    print("Loaded completed puzzles: $completedPuzzles");
  }

  Future<void> updatePuzzleCompletion(String category, int rows, int cols) async {
    final prefs = await SharedPreferences.getInstance();
    String key = 'completed_${category}_${rows}x${cols}';

    int currentCount = completedPuzzles[key] ?? 0;  
    currentCount++;

    await prefs.setInt(key, currentCount);
    completedPuzzles[key] = currentCount; // Update GetX state

    print("Updated completedPuzzles for $key: ${completedPuzzles[key]}");
  }
}
