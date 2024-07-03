part of '../xwordle.dart';

Handler inlineHandler() {
  return (ctx) async {
    final builder = InlineQueryResultBuilder();
    if (ctx.from == null) {
      await ctx.answerInlineQuery([]);
      return;
    }
    final user = await WordleUser.init(ctx.from!.id);
    final game = gameNo();
    final word = getWord(game);

    if (user.lastGame == game) {
      final msg = getShareMessage(
        word,
        user.tries,
        game,
        user: user,
      );
      builder.article(
        getRandomString(),
        "🎉 Shre your result",
        (i) {
          return i.text(
            "Just finished a game at @xWordleBot. Here's my result:\n\n$msg",
          );
        },
        description:
            "Tap to share your today's wordle game result with your friends and chats.",
      );
    }

    final invites = [
      "Guess the word of the day with me! Join the Wordle craze inside Telegram with @xWordleBot.",
      "Hey, wanna play Wordle without leaving Telegram? Check out this awesome bot: @xWordleBot!",
      "Challenge yourself with Wordle on Telegram! Play now with @xWordleBot.",
      "Looking for a fun word game? Try Wordle on Telegram with @xWordleBot!",
      "Let's see who can guess the word first! Play Wordle with @xWordleBot.",
      "Join the word-guessing fun on Telegram with @xWordleBot!",
      "Can't get enough of Wordle? Play it on Telegram with @xWordleBot.",
      "Test your vocabulary skills with Wordle Bot! Start playing at @xWordleBot.",
      "Wordle is now on Telegram! Join the game with @xWordleBot.",
      "Discover the word of the day with Wordle Bot on Telegram! Try it now at @xWordleBot."
    ];

    builder.article(
      getRandomString(),
      "👫 Invite a friend",
      (i) {
        return i.text(random(invites));
      },
      description:
          "Invite your friend to the Wordle Bot and challenge each other",
      replyMarkup: InlineKeyboard().addUrl(
        "🎮 Start Playing",
        "https://t.me/xwordlebot?start=${ctx.from?.id}",
      ),
    );

    await ctx.answerInlineQuery(
      builder.build(),
      button: InlineQueryResultsButton(
        text: "Wordle Hero Needed 🦸🏻",
        startParameter: "donate",
      ),
    );
  };
}
