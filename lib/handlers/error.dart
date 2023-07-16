import 'package:xwordle/utils/utils.dart';

Future<void> errorHandler(Object err, StackTrace stack) async {
  try {
    await sendLogs("💀 $err\n\n$stack\n\n#error");
  } catch (err, stack) {
    print("Error while sending error to logs channel: $err");
    print(stack);
  }
}
