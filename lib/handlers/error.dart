import 'package:xwordle/config/config.dart';
import 'package:xwordle/xwordle.dart';

Future<void> errorHandler(Object err, StackTrace stack) async {
  try {
    await bot.api.sendMessage(
      WordleConfig.instance.logsChannel,
      "$err\n\n$stack",
    );
  } catch (err, stack) {
    print("Error while sending error to logs channel: $err");
    print(stack);
  }
}
