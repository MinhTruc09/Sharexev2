// extensions.dart
import 'dart:ui';

/// Provides convenient color manipulation methods
extension ColorExtensions on Color {
  /// Creates a new color with specified alpha, keeping other channels
  Color withValues({int? alpha, int? red, int? green, int? blue}) {
    return Color.fromARGB(
      alpha ?? this.alpha,
      red ?? this.red,
      green ?? this.green,
      blue ?? this.blue,
    );
  }
}
