import 'package:confetti/confetti.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PuzzleProgressController extends GetxController {
  var completedPuzzles =
      <String, int>{}.obs; // Reactive map for completed puzzles

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

  Future<void> updatePuzzleCompletion(
    String category,
    int rows,
    int cols,
    int completedIndex,
    int totalImages,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    String key = 'completed_${category}_${rows}x${cols}';

    int currentCount = completedPuzzles[key] ?? 0;

    // ✅ Don't increase the count if it's already solved
    if (completedIndex < currentCount) {
      print(
        "Puzzle already solved. No update needed for $key at index $completedIndex.",
      );
      return;
    }

    currentCount++; // Only increment if not already solved

    await prefs.setInt(key, currentCount);
    completedPuzzles[key] = currentCount;
    FlameAudio.play('level_up.mp3', volume: 1);

    print("Updated completedPuzzles for $key: ${completedPuzzles[key]}");

    // ✅ Unlock the next puzzle if this was the last one
    if (completedIndex == totalImages - 1) {
      await prefs.setBool('unlocked_$category image', true);
      print("🎉 Last puzzle solved in $category — Image unlocked!");
    }
  }
}
