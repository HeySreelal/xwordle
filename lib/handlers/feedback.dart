part of xwordle;

/// Handles the feedback command
MessageHandler feedbackHandler() {
  return (ctx) async {
    await ctx.reply(random(MessageStrings.feedbackPrompts));
    await ctx.reply("Just know you can send /cancel to sending the feedback.");
    final replyCtx = await conv.waitForTextMessage(chatId: ctx.id);

    if (replyCtx.message.text == "/cancel") {
      await ctx.reply(
        "I guess you changed your mind. Feel free to send feedback anytime.",
        replyMarkup: ReplyKeyboardRemove(),
      );
      return;
    }

    await replyCtx.reply("Thanks for your feedback! Happy Wordling! 🤓");
    final feedbackMeta = "💬 Feedback\n"
        "--------------\n\n"
        "From: ${ctx.chat.firstName} ${ctx.chat.lastName ?? ''}\n"
        "ID: ${ctx.chat.id}\n\n";
    final feedbackMessage =
        "$feedbackMeta${replyCtx.message.text ?? ""}\n\n#feedback";

    List<MessageEntity>? entities = replyCtx.message.entities?.map((e) {
      return MessageEntity(
        type: e.type,
        offset: e.offset + feedbackMeta.length,
        length: e.length,
        url: e.url,
        user: e.user,
        language: e.language,
        customEmojiId: e.customEmojiId,
      );
    }).toList();

    await ctx.api.sendMessage(
      WordleConfig.instance.logsChannel,
      feedbackMessage,
      entities: entities,
      disableWebPagePreview: true,
    );
  };
}

/// It's possible that users send feedback that is a question. This handler
/// will be used to respond to such questions.
///
/// This handler will be called by the admin's channel post to the logs channel.
Future<void> respondToFeedback(MessageContext ctx) async {
  final response = ctx.message.text;
  if (response == null) return;

  final replyToMessage = ctx.message.replyToMessage;
  if (replyToMessage == null) return;
  final RegExp matchID = RegExp(r"ID: (\d+)");
  final idOfTheUser = matchID.firstMatch(replyToMessage.text!)?.group(1);
  final chatId = ChatID(int.parse(idOfTheUser!));

  await ctx.api.sendMessage(
    chatId,
    "$response\n\n💬 - Admin",
    entities: ctx.message.entities,
  );
  await ctx.api.sendMessage(
    chatId,
    "ℹ️ This is a response from the admin about your feedback. Please note that replies to this message will not be seen by the admin. If you have any further questions, reach us at @XooniverseChat or using /feedback again.",
  );
}
