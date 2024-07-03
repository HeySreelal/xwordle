part of '../xwordle.dart';

Handler meaningHandler() {
  return (ctx) async {
    WordleDay day = await WordleDB.today();
    WordleUser user = WordleUser.init(ctx.id.id);

    if (user.lastGame != day.index) {
      await ctx.reply(random(MessageStrings.meaningBeforePlayingResponse));
      return;
    }

    Word word;

    if (day.dictionaryWord != null && day.dictionaryWord!.word == day.word) {
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
    day.meaningCheckCount++;
    day.save();
  };
}
