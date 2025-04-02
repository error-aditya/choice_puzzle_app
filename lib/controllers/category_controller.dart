import 'package:get/get.dart';

class CategoryController extends GetxController {
  var selectedCategory = 'Animals'.obs; // Default category

  void updateCategory(String newCategory) {
    selectedCategory.value = newCategory;
  }
}
