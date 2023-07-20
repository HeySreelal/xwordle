part of xwordle;

MessageHandler cancelHandler() {
  return (ctx) async {
    await ctx.reply(
      random(MessageStrings.nothingToCancel),
      replyMarkup: ReplyKeyboardRemove(),
    );
  };
}
