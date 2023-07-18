import 'package:xwordle/config/config.dart';
import 'package:xwordle/utils/utils.dart';

Future<void> errorHandler(Object err, StackTrace stack) async {
  try {
    if (WordleConfig.isDebug) {
      print("Error: $err");
      print(stack);
      return;
    }
    await sendLogs("💀 $err\n\n$stack\n\n#error");
  } catch (err, stack) {
    print("Error while sending error to logs channel: $err");
    print(stack);
  }
}
