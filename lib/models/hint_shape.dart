part of '../xwordle.dart';

/// The wordle hint shape, used to display the hint
enum HintShape {
  circle._("🟢", "⚫️", "🟡"),
  square._("🟩", "⬛️", "🟨"),
  heart._("💚", "🖤", "💛"),
  ;

  final String correct;
  final String wrong;
  final String misplaced;

  const HintShape._(this.correct, this.wrong, this.misplaced);

  String get name => toString().split('.').last;

  static HintShape fromName(String name) {
    return HintShape.values.firstWhere(
      (e) => e.name == name,
      orElse: () => HintShape.circle,
    );
  }

  static HintShape fromText(String text) {
    return HintShape.values.firstWhere(
      (e) => text.toLowerCase().contains(e.name.toLowerCase()),
      orElse: () => HintShape.circle,
    );
  }

  String get shapes {
    return "$correct $misplaced $wrong";
  }

  static HintShape random() {
    return HintShape.values[Random().nextInt(HintShape.values.length)];
  }

  static const circleText = "Circle 🟢";
  static const squareText = "Square 🟨";
  static const heartText = "Heart 🖤";
  static const randText = "Random 🎲";
}
