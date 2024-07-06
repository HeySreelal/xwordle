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
        thumbnailUrl: "https://xwordle.web.app/assets/result.png",
      );
    }

    final invites = [
      "Guess the word of the day with me! Join the Wordle craze inside Telegram with Wordle Bot.",
      "Hey, wanna play Wordle without leaving Telegram? Check out this awesome bot: Wordle Bot!",
      "Challenge yourself with Wordle on Telegram! Play now with Wordle Bot.",
      "Looking for a fun word game? Try Wordle on Telegram with Wordle Bot!",
      "Let's see who can guess the word first! Play Wordle with Wordle Bot.",
      "Join the word-guessing fun on Telegram with Wordle Bot!",
      "Can't get enough of Wordle? Play it on Telegram with Wordle Bot.",
      "Test your vocabulary skills with Wordle Bot! Start playing at Wordle Bot.",
      "Wordle is now on Telegram! Join the game with Wordle Bot.",
      "Discover the word of the day with Wordle Bot on Telegram! Try it now at Wordle Bot."
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
        "https://t.me/xclairebot?start=${ctx.from?.id}",
      ),
      thumbnailUrl: "https://xwordle.web.app/assets/invite.png",
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
