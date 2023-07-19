part of xwordle;



/// Handles the /help command
MessageHandler helpHandler() {
  return (ctx) async {
    await ctx.reply(
      MessageStrings.helpMessage,
      parseMode: ParseMode.html,
    );
  };
}

/// Handles the /about command
MessageHandler aboutHandler() {
  return (ctx) async {
    await ctx.reply(
      MessageStrings.aboutMessage,
      parseMode: ParseMode.html,
    );
  };
}
