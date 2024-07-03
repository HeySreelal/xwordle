part of '../xwordle.dart';

/// Pattern used to match donation method
final donatePattern = RegExp(r"donate:(.*)");

/// Pattern used to match star count callback query
final starsCountPattern = RegExp(r"stars:(.*)");

Handler donateHandler() {
  const kdonate = "donate";

  final board = InlineKeyboard()
      .add("Telegram Stars ⭐️", "$kdonate:stars")
      .row()
      .add("💎 TON", "$kdonate:ton")
      .add("💰 USDT", "$kdonate:usdt")
      .row()
      .add("👛 Solana", "$kdonate:sol");
  return (ctx) async {
    ctx.reply(
      "🙏 Thank you so much for considering a donation to support Wordle Bot! Your generosity helps keep this project running."
      "\n\nPlease choose a preferred donation method from below and we'll provide you with the necessary details. Your support means a lot! 💖",
      replyMarkup: board,
    );
  };
}

enum DonationMethod {
  stars("stars"),
  ton("ton"),
  usdt("usdt"),
  sol("sol"),
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

Handler donateCallbackHandler() {
  final countBoard = InlineKeyboard();
  for (var op in DonateOption.options) {
    countBoard.add("$op", "stars:${op.count}");
    countBoard.row();
  }

  return (ctx) async {
    final data = ctx.callbackQuery!.data!;
    final method = DonationMethod.fromString(data.split(":")[1]);
    final text = switch (method) {
      DonationMethod.stars => MessageStrings.starDonationPrompt,
      DonationMethod.ton => MessageStrings.tonDonation.replaceAll(
          "{ADDRESS1}",
          WordleConfig.env["TON_ADDRESS"],
        ),
      DonationMethod.usdt => MessageStrings.usdtDonation
          .replaceAll(
            "{ADDRESS1}",
            WordleConfig.env["USDT_TRC20"],
          )
          .replaceAll(
            "{ADDRESS2}",
            WordleConfig.env["USDT_ON_TON"],
          ),
      DonationMethod.sol => MessageStrings.solDonation
          .replaceAll(
            "{ADDRESS1}",
            WordleConfig.env["SOL_ON_SOLANA"],
          )
          .replaceAll(
            "{ADDRESS2}",
            WordleConfig.env["SOL_ON_BEP20"],
          ),
    };

    final b = method == DonationMethod.stars ? countBoard : InlineKeyboard();

    await ctx.editMessageText(
      text,
      replyMarkup: b,
      parseMode: ParseMode.html,
    );
  };
}

Handler starsCountSelectionHandler() {
  return (ctx) async {
    int count;
    try {
      final d = ctx.callbackQuery!.data!.split(":")[1];
      count = int.tryParse(d) ?? 99;
    } catch (_) {
      count = 99;
    }
    final op = DonateOption.find(count);
    await ctx.editMessageText(
      "Thanks for choosing $op. Every star counts, and yours makes a difference!",
      replyMarkup: InlineKeyboard(),
    );
    await ctx.sendInvoice(
      title: "Wordle Bot Donation",
      description: MessageStrings.donationDescription,
      payload: "donation",
      currency: "XTR",
      providerToken: "",
      prices: [
        LabeledPrice(label: "Coffee Boost", amount: count),
      ],
    );
  };
}

// Define a function to check if the user should be nudged to donate
bool shouldNudgeToDonate() {
  // Adjust the probability as desired, for example, 30% chance
  return Random().nextInt(100) < 30; // 30% chance
}

void nudgeDonation(
  Context ctx, {
  bool straight = false,
}) async {
  final nudges = [
    "🌟 Enjoying Wordle Bot? <tg-spoiler>Consider supporting us with a donation! Use /donate to learn more.</tg-spoiler>",
    "Loving the Wordle Bot experience? <tg-spoiler>Fuel the fun with a donation! Use /donate to show your love! ❤️</tg-spoiler>",
    "<tg-spoiler>Can't get enough of Wordle Bot? Help us keep it going strong with a donation! Use /donate to become a hero!</tg-spoiler>",
    "<tg-spoiler>Feeling lucky in Wordle Bot? Share the luck with a donation! Use /donate to keep the good times rolling! </tg-spoiler>",
  ];
  // Optionally nudge the user to donate randomly
  if (!straight ? shouldNudgeToDonate() : true) {
    try {
      await ctx.reply(
        random(nudges),
        parseMode: ParseMode.html,
      );
    } catch (e, stack) {
      errorHandler(BotError(e, stack)).ignore();
    }
  }
}
