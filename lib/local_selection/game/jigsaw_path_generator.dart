import 'dart:ui';
import 'package:flame/components.dart';

class JigsawPathGenerator {
  static Path generatePath(double width, double height, int row, int col, int rows, int cols) {
    final Path path = Path();
    const double knobSize = 20.0; // Adjust for a better fit

    path.moveTo(0, 0);
    path.lineTo(width, 0); // Top side

    if (row < rows - 1) {
      _addKnob(path, width, 0, false);
    }

    path.lineTo(width, height);

    if (col < cols - 1) {
      _addKnob(path, width, height, true);
    }

    path.lineTo(0, height);

    if (row > 0) {
      _addKnob(path, 0, height, false, invert: true);
    }

    path.lineTo(0, 0);

    path.close();
    return path;
  }

  static void _addKnob(Path path, double x, double y, bool horizontal, {bool invert = false}) {
    const double knobSize = 20.0;
    final double direction = invert ? -1 : 1;

    if (horizontal) {
      path.quadraticBezierTo(x + knobSize * 0.5 * direction, y - knobSize * 0.5,
          x + knobSize * direction, y);
      path.quadraticBezierTo(x + knobSize * 0.5 * direction, y + knobSize * 0.5,
          x, y);
    } else {
      path.quadraticBezierTo(x - knobSize * 0.5, y + knobSize * 0.5 * direction,
          x, y + knobSize * direction);
      path.quadraticBezierTo(x + knobSize * 0.5, y + knobSize * 0.5 * direction,
          x, y);
    }
  }
}
