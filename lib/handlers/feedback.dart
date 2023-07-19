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
