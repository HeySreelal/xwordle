part of '../xwordle.dart';

Handler chatMemberHandler() {
  return (ctx) async {
    final enc = JsonEncoder.withIndent('  ');
    print("Fuck this is called!");
    final up = enc.convert(ctx.update.toJson());
    print(up);
    final cm = ctx.chatMember;
    if (cm == null) return;
    if (cm.chat.username != "xooniverse") {
      await sendLogs(
        'Got a <code>ChatMember</code> update of different chat.\n\n<pre><code class="language-json">$up</code></pre>',
      );
      return;
    }

    final user = await WordleUser.init(cm.from.id);

    final isMember = cm.newChatMember.status == ChatMemberStatus.member;
    final notClaimed = !user.hasClaimedXooniverseOffer;

    if (isMember && notClaimed) {
      user.hints.extraAttempts.left += 3;
      user.hints.letterReveals.left += 3;
      user.hasClaimedXooniverseOffer = true;
      await user.save();
      try {
        final message = await api.sendMessage(
          ChatID(user.id),
          "You have been credited with Bonus Hints Pack with Letter Reveal x3 and Extra Attempt x3!\n\n<blockquote>Woohoo! Thanks for jumping into @Xooniverse! We're happy to have you. Here's a little something to show our appreciation! 🎉</blockquote>",
          messageEffectId: kPartyEffectId,
          parseMode: ParseMode.html,
        );
        await sendLogs(
          'Sent bonus to ${user.id}\n\n<pre><code class="language-json">${enc.convert(message.toJson())}</code></pre>',
        );
      } catch (err, stack) {
        errorHandler(BotError(err, stack)).ignore();
      }
    }
  };
}
