part of xwordle;

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

MessageHandler shapeHandler() {
  return (ctx) async {
    final txt = random(MessageStrings.shapesPrompts);

    await ctx.reply(txt, replyMarkup: hintShapesKeyboard);
    await ctx.reply("Just know you can send /cancel to cancel the command.");
    final reply = await conv.waitForTextMessage(chatId: ctx.id);
    await setShapeHandler(reply);
  };
}

Future<bool> setShapeHandler(MessageContext ctx) async {
  WordleUser user = ctx.session as WordleUser;

  do {
    if (ctx.message.text?.isEmpty ?? true) {
      await ctx.reply("Please choose from the keyboard.");
      continue;
    }

    if (ctx.message.text == "/cancel") {
      await ctx.reply(
        "Got it, let's do this later.",
        replyMarkup: ReplyKeyboardRemove(),
      );
      return false;
    }

    final text = ctx.message.text;
    if (text != HintShape.circleText &&
        text != HintShape.squareText &&
        text != HintShape.heartText &&
        text != HintShape.randText) {
      await ctx.reply(
        "Uh oh, I didn't understand that. Please choose from the keyboard.",
        replyMarkup: hintShapesKeyboard,
      );
      continue;
    }

    if (text == HintShape.randText) {
      user.hintShape = HintShape.random();
    } else {
      user.hintShape = HintShape.fromText(text!);
    }

    user.saveToFile();
    await ctx.reply(
      "Your hint shape has been updated to <b>${user.hintShape.name.toUpperCase()}</b> ${user.hintShape.shapes}",
      parseMode: ParseMode.html,
      replyMarkup: ReplyKeyboardRemove(),
    );
    return true;
  } while (true);
}
