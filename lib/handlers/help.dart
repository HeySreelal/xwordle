part of '../xwordle.dart';

/// Handles the /help command
Handler helpHandler() {
  return (ctx) async {
    await ctx.reply(
      MessageStrings.helpMessage,
      parseMode: ParseMode.html,
    );
  };
}

/// Handles the /about command
Handler aboutHandler() {
  return (ctx) async {
    await ctx.reply(
      MessageStrings.aboutMessage,
      parseMode: ParseMode.html,
    );
  };
}
