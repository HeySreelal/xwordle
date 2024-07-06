part of '../xwordle.dart';

const milestoneInfoPattern = "milestone";

Handler inviteHandler() {
  return (ctx) async {
    final (user, _) = await getUserAndGame(ctx.id.id);
    final name = ctx.from!.firstName;
    final link = "https://t.me/xwordlebot?start=${ctx.id.id}";
    final component = Uri.encodeComponent(
      "Challenge yourself with Wordle on Telegram! Start playing by tapping the invite link.",
    );
    final shareUrl = "https://t.me/share/url?url=$link&text=$component";
    final msg = MessageStrings.referralInfo
        .replaceAll("{NAME}", name)
        .replaceAll("{INVITE_LINK}", link)
        .replaceAll("{INVITE_COUNT}", "${user.referralCount}");
    final board = InlineKeyboard()
        .addUrl("Share Invite 💌", shareUrl)
        .row()
        .add("Milestones?", milestoneInfoPattern);
    await ctx.reply(
      msg,
      parseMode: ParseMode.html,
      replyMarkup: board,
    );
    await ctx.reply(
      "Pro Tip: You can also get your invite in any chat just by typing @xwordlebot.",
      replyMarkup: InlineKeyboard().switchInlineQuery("Try it now 😎"),
    );
  };
}

Handler milestoneInfoHandler() {
  return (ctx) async {
    await ctx.reply(
      MessageStrings.milestoneInfo,
      parseMode: ParseMode.html,
    );
  };
}
