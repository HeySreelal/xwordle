part of '../xwordle.dart';

Handler cancelHandler() {
  return (ctx) async {
    await ctx.reply(
      random(MessageStrings.nothingToCancel),
      replyMarkup: ReplyKeyboardRemove(),
    );
  };
}
