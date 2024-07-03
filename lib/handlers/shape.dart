part of '../xwordle.dart';

final hintShapesKeyboard = Keyboard()
    .addText(HintShape.circleText)
    .row()
    .addText(HintShape.squareText)
    .row()
    .addText(HintShape.heartText)
    .row()
    .addText(HintShape.randText)
    .oneTime()
    .resized();

Handler shapeHandler() {
  return (ctx) async {
    final txt = random(MessageStrings.shapesPrompts);

    await ctx.reply(txt, replyMarkup: hintShapesKeyboard);
    await ctx.reply("Just know you can send /cancel to cancel the command.");

    await setShapeHandler(ctx.id);
  };
}

Future<bool> setShapeHandler(ID chatId) async {
  int tries = 0;
  do {
    if (tries >= 3) {
      await bot.api.sendMessage(
        chatId,
        "I'm sorry, I didn't understand that. I'm cancelling shape selection. Please try again later.",
        replyMarkup: ReplyKeyboardRemove(),
      );
      return false;
    }
    final ctx = await conv.waitForTextMessage(chatId: chatId);
    WordleUser user = await WordleUser.init(ctx?.id.id);
    if (ctx?.message?.text?.isEmpty ?? true) {
      await ctx?.reply("Please choose from the keyboard.");
      tries++;
      continue;
    }

    if (ctx?.message?.text == "/cancel") {
      await ctx?.reply(
        "Got it, let's do this later.",
        replyMarkup: ReplyKeyboardRemove(),
      );
      return false;
    }

    final text = ctx?.message?.text;
    if (text != HintShape.circleText &&
        text != HintShape.squareText &&
        text != HintShape.heartText &&
        text != HintShape.randText) {
      tries++;

      await ctx?.reply(
        "Uh oh, I didn't understand that. Please choose a valid shape from the keyboard. Or send /cancel to cancel the command.",
        replyMarkup: hintShapesKeyboard,
      );
      continue;
    }

    if (text == HintShape.randText) {
      user.hintShape = HintShape.random();
    } else {
      user.hintShape = HintShape.fromText(text!);
    }

    user.save();
    await ctx?.reply(
      "Your hint shape has been updated to <b>${user.hintShape.name.toUpperCase()}</b> ${user.hintShape.shapes}",
      parseMode: ParseMode.html,
      replyMarkup: ReplyKeyboardRemove(),
    );
    break;
  } while (true);
  return true;
}
