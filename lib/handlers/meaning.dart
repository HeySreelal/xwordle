import 'package:televerse/televerse.dart';
import 'package:xwordle/config/consts.dart';
import 'package:xwordle/config/day.dart';
import 'package:xwordle/models/user.dart';
import 'package:xwordle/services/db.dart';
import 'package:xwordle/services/dict.dart';
import 'package:xwordle/utils/utils.dart';

MessageHandler meaningHandler() {
  return (ctx) async {
    WordleDay day = WordleDB.today;
    WordleUser user = ctx.session as WordleUser;

    if (user.lastGame != day.index) {
      await ctx.reply(random(MessageStrings.meaningBeforePlayingResponse));
      return;
    }

    Word word;

    if (day.dictionaryWord != null) {
      word = day.dictionaryWord!;
    } else {
      final w = await Dictionary(day.word).getWord();
      if (w == null) {
        await ctx.reply(random(MessageStrings.meaningError));
        return;
      }
      word = w;
      day.meaning = word;
    }
    final msg = word.formattedFirstMeaning();
    await ctx.reply(
      msg,
      parseMode: ParseMode.html,
    );
  };
}
