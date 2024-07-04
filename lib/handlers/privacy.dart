part of '../xwordle.dart';

Handler privacyHandler() {
  return (ctx) async {
    await ctx.replyWithPhoto(
      InputFile.fromUrl("https://xwordle.web.app/assets/privacy.png"),
      caption: MessageStrings.privacyText,
      replyMarkup: InlineKeyboard().addUrl(
        "📖 Privacy Statement",
        "https://xwordlebot.web.app/privacy.html",
      ),
    );
  };
}
