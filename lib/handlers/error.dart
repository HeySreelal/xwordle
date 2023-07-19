import 'package:televerse/telegram.dart';
import 'package:televerse/televerse.dart';
import 'package:xwordle/config/config.dart';
import 'package:xwordle/utils/utils.dart';

Future<void> errorHandler(Object err, StackTrace stack) async {
  try {
    if (WordleConfig.isDebug) {
      print("Error: $err");
      print(stack);
      return;
    }
    if (err is TelegramException && err.isServerExeption) {
      DateTime now = DateTime.now();
      Message? msg;
      while (msg == null) {
        try {
          msg = await sendLogs(
            "⚠️ <b>Server Error</b>\n\n"
            "<b>Time:</b> ${now.toIso8601String()}\n"
            "<b>Message:</b> $err\n"
            "<b>Stack:</b> $stack\n\n"
            "#error",
          );
        } catch (err) {
          print("Error ignored: $err");
          await Future.delayed(Duration(minutes: 30));
        }
      }
      return;
    }
    await sendLogs("💀 $err\n\n$stack\n\n#error");
  } catch (err, stack) {
    print("Error while sending error to logs channel: $err");
    print(stack);
  }
}
