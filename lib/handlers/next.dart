import 'package:televerse/televerse.dart';
import 'package:xwordle/config/consts.dart';
import 'package:xwordle/services/db.dart';
import 'package:xwordle/utils/utils.dart';

/// Handles the /next command
///
/// This command is used to tell the user how much time is left for the next
/// word to be available.
MessageHandler nextWordHandler() {
  return (ctx) async {
    final game = WordleDB.today;
    final msg = random(MessageStrings.excitedMessages).replaceAll(
      "{TIME}",
      game.formattedDurationTillNext,
    );
    await ctx.reply(msg);
  };
}
