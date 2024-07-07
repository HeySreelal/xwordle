import 'package:televerse/televerse.dart';
import 'package:xwordle/xwordle.dart';

const releasenote = """
Hey Wordler!

In our last post, we promised exciting new features, and here we are with the first of them. 😎

<b>Introducing Hints!</b> We know there were times you missed that one letter on your last try. We know the frustration of being so close yet so far from victory. Well, we've got your back with a small hint to turn the tide. Also, ever wished for one more attempt on your final guess?

Yes, we're bringing hints to the game with two new types:

1. <b>Letter Reveal</b>
This feature reveals one letter that you couldn't figure out. The bot will choose the optimal letter based on your guesses in that game. 🎰

2. <b>Extra Attempt</b>
Get an extra chance to guess the word without it counting as a regular try. Consider it a little cheat that's allowed. 😉

To get you started, we've added two of each hint to your account. Being said that, Hints are a premium feature, and you can find all the details and start using hints with the /hint command.

😎 Bonus! Want to earn hints for free? Invite your friends with your referral link and unlock hints as rewards. We've set up milestones for the invite program. Each milestone you reach will reward you with exciting hint packs. Use the /invite command to get your referral link. For a simpler way to invite friends, just type @xwordlebot in any chat to share your invite link instantly.

We’ve also fixed an issue with the /donate command in this release. Well, just in case you're considering to donate some ❤️ <tg-spoiler> as stars ⭐️, you know :)</tg-spoiler>.

Stay tuned to @Xooniverse for more updates, and feel free to send us your feedback with the /feedback command.

---
TL;DR
- Introducing Hints. Use /hints command to get full info.
- We added an invite program with cool rewards. Use /invite to get your invite link.
- Fixed issues with /donate method

Happy Wordling!
""";

void main(List<String> args) async {
  final board = InlineKeyboard().addUrl(
    "Open Wordle Bot 🤖",
    "https://t.me/xwordlebot",
  );
  await api.sendMessage(
    ChannelID("@xooniverse"),
    releasenote,
    parseMode: ParseMode.html,
    replyMarkup: board,
  );
}
