import 'package:televerse/televerse.dart';
import 'package:xwordle/config/consts.dart';
import 'package:xwordle/models/user.dart';
import 'package:xwordle/services/db.dart';
import 'package:xwordle/utils/utils.dart';

MessageHandler startHandler() {
  return (MessageContext ctx) async {
    final game = WordleDB.today;
    final user = ctx.session as WordleUser;
    if (user.name == WordleUser.defaultName && ctx.message.from != null) {
      user.name = ctx.message.from!.firstName;
    }

    if (game.index == user.lastGame) {
      final msg = random(MessageStrings.excitedMessages).replaceAll(
        "{TIME}",
        game.formattedDurationTillNext,
      );
      await ctx.reply(
        msg,
        replyToMessageId: ctx.message.messageId,
      );
      return;
    }

    /// If the user is already playing a game, tell them to finish it first
    if (user.onGame && user.currentGame == game.index) {
      await ctx.api.sendChatAction(ctx.id, ChatAction.typing);
      await ctx.reply(MessageStrings.alreadyPlaying);
      return;
    }

    /// Let's start a new game
    await ctx.api.sendChatAction(ctx.id, ChatAction.typing);
    await ctx.reply(MessageStrings.letsStart, parseMode: ParseMode.html);
    user.onGame = true;
    game.totalPlayed++;
    if (user.currentGame != game.index) {
      user.currentGame = game.index;
      user.tries = [];
      user.totalGamesPlayed++;
    }
    user.saveToFile();
    game.save();
  };
}
