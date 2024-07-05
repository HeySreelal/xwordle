part of '../xwordle.dart';

class Plan {
  final String title;
  final String description;
  final String payload;
  final int amount;
  final int extraAttemptCount;
  final int letterRevealCount;

  const Plan({
    required this.title,
    required this.amount,
    required this.payload,
    required this.description,
    this.extraAttemptCount = 0,
    this.letterRevealCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "description": description,
      "payload": payload,
      "amount": amount,
      "extraAttemptCount": extraAttemptCount,
      "letterRevealCount": letterRevealCount,
    };
  }

  static String generateDescription(String powerUpType, int count, int amount) {
    return "You can use this power-up to ${powerUpType == 'Letter Reveal' ? 'reveal a letter from the actual word' : 'guess the word without including it on your 6 tries'}. You will receive $count $powerUpType power up for $amount ⭐️.\n\nPlease continue to purchase by tapping the button below.";
  }

  static String generateBundleDescription(
      String bundleName, int letterReveals, int extraAttempts) {
    return "This pack includes $letterReveals Letter Reveals and $extraAttempts Extra Attempt power-ups. ${bundleName == 'Wordle Kickstart Bundle' ? 'Get a head start with a mix of hints!' : bundleName == 'Wordle Advantage Pack' ? 'Perfect for more chances and reveals to boost your game!' : 'Master the game with plenty of hints!'} Please continue to purchase by tapping the button below.";
  }

  static final all = [
    Plan(
      title: "Letter Reveal x1",
      amount: 35,
      description: generateDescription('Letter Reveal', 1, 35),
      payload: "$letterreveal:1",
      letterRevealCount: 1,
    ),
    Plan(
      title: "Letter Reveal x3",
      amount: 105,
      description: generateDescription('Letter Reveal', 3, 105),
      payload: "$letterreveal:3",
      letterRevealCount: 3,
    ),
    Plan(
      title: "Letter Reveal x5",
      amount: 175,
      description: generateDescription('Letter Reveal', 5, 175),
      payload: "$letterreveal:5",
      letterRevealCount: 5,
    ),
    Plan(
      title: "Extra Attempt x1",
      amount: 75,
      description: generateDescription('Extra Attempt', 1, 75),
      payload: "$extraattempt:1",
      extraAttemptCount: 1,
    ),
    Plan(
      title: "Extra Attempt x3",
      amount: 225,
      description: generateDescription('Extra Attempt', 3, 225),
      payload: "$extraattempt:3",
      extraAttemptCount: 3,
    ),
    Plan(
      title: "Extra Attempt x5",
      amount: 299,
      description: generateDescription('Extra Attempt', 5, 299),
      payload: "$extraattempt:5",
      extraAttemptCount: 5,
    ),
    Plan(
      title: "Wordle Kickstart Bundle",
      amount: 149,
      payload: buykickstart,
      description: generateBundleDescription('Wordle Kickstart Bundle', 3, 1),
      letterRevealCount: 3,
      extraAttemptCount: 1,
    ),
    Plan(
      title: "Wordle Advantage Pack",
      amount: 299,
      payload: buyadvantage,
      description: generateBundleDescription('Wordle Advantage Pack', 7, 3),
      letterRevealCount: 7,
      extraAttemptCount: 3,
    ),
    Plan(
      title: "Wordle Domination Kit",
      amount: 699,
      payload: buydomination,
      description: generateBundleDescription('Wordle Domination Kit', 15, 7),
      letterRevealCount: 15,
      extraAttemptCount: 7,
    ),
  ];
}
