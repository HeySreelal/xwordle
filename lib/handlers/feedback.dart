import 'package:televerse/telegram.dart';
import 'package:televerse/televerse.dart';
import 'package:xwordle/config/config.dart';
import 'package:xwordle/config/consts.dart';
import 'package:xwordle/utils/utils.dart';
import 'package:xwordle/xwordle.dart';

/// Handles the feedback command
MessageHandler feedbackHandler() {
  return (ctx) async {
    await ctx.reply(random(MessageStrings.feedbackPrompts));
    await ctx.reply("Just know you can send /cancel to sending the feedback.");
    final replyCtx = await conv.waitForTextMessage(chatId: ctx.id);
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
