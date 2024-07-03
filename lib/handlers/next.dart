part of '../xwordle.dart';

/// Handles the /next command
///
/// This command is used to tell the user how much time is left for the next
/// word to be available.
Handler nextWordHandler() {
  return (ctx) async {
    final game = await WordleDB.today();
    final msg = random(MessageStrings.excitedMessages).replaceAll(
      "{TIME}",
      game.formattedDurationTillNext,
    );
    await ctx.reply(msg);
  };
}
