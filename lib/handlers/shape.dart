import 'package:televerse/telegram.dart';
import 'package:televerse/televerse.dart';
import 'package:xwordle/config/consts.dart';
import 'package:xwordle/models/user.dart';
import 'package:xwordle/utils/utils.dart';
import 'package:xwordle/xwordle.dart';

MessageHandler shapeHandler() {
  return (ctx) async {
    WordleUser user = ctx.session as WordleUser;
    const circle = "Circle 🟢";
    const square = "Square 🟩";
    const heart = "Heart 💚";
    const rand = "Random 🎲";

    final keyboard = Keyboard()
        .addText(circle)
        .row()
        .addText(square)
        .row()
        .addText(heart)
        .row()
        .addText(rand)
        .oneTime()
        .resized();

    final txt = random(MessageStrings.shapesPrompts);

    await ctx.reply(txt, replyMarkup: keyboard);

    do {
      final reply = await conv.waitForTextMessage(chatId: ctx.id);
      if (reply.message.text?.isEmpty ?? true) {
        await ctx.reply("Please choose from the keyboard.");
        continue;
      }

      final text = reply.message.text;
      if (text != circle && text != square && text != heart && text != rand) {
        await ctx.reply(
          "Uh oh, I didn't understand that. Please choose from the keyboard.",
          replyMarkup: keyboard,
        );
        continue;
      }

      if (text == rand) {
        user.hintShape = HintShape.random();
      } else {
        user.hintShape = HintShape.fromName(text!);
      }

      user.saveToFile();
      await ctx.reply(
        "Your hint shape has been updated to <b>${user.hintShape.name.toUpperCase()}</b> ${user.hintShape.shapes}",
        parseMode: ParseMode.html,
        replyMarkup: ReplyKeyboardRemove(),
      );
      break;
    } while (true);
  };
}
