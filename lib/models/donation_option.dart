part of '../xwordle.dart';

class DonateOption {
  final String name;
  final int count;

  DonateOption(this.name, this.count);

  static List<DonateOption> options = [
    DonateOption("Coffee Boost", 99),
    DonateOption("Lucky Clover", 199),
    DonateOption("Hero's Charge", 499),
    DonateOption("Dev's Delight", 999),
    DonateOption("Game Changer", 1999),
  ];

  static DonateOption find(int price) {
    return options.firstWhere((e) => e.count == price);
  }

  @override
  String toString() => "$name ⭐️ $count";
}

enum DonationMethod {
  stars("stars"),
  ;

  final String key;
  const DonationMethod(this.key);

  static DonationMethod fromString(String k) {
    return values.firstWhere(
      (e) => e.key == k,
      orElse: () => stars,
    );
  }
}
