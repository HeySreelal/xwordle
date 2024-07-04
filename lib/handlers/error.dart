part of '../xwordle.dart';

Future<void> errorHandler(BotError error) async {
  final Object err = error.error;
  final StackTrace stack = error.stackTrace;

  void logError(Object err, StackTrace stack) {
    if (WordleConfig.isDebug) {
      print("Error: $err");
      print(stack);
    } else {
      print("💀 $err\n\n$stack\n\n#error");
    }
  }

  try {
    logError(err, stack);
    if (WordleConfig.isDebug) {
      return;
    }

    if (err is TelegramException) {
      DateTime now = DateTime.now();
      int retryCount = 0;
      const int maxRetries = 3;

      while (retryCount < maxRetries) {
        try {
          await sendLogs(
            "⚠️ <b>Server Error</b>\n\n"
            "<b>Time:</b> ${now.toIso8601String()}\n"
            "<b>Message:</b> $err\n"
            "<b>Stack:</b> ${stack.toString()}\n\n"
            "#error",
          );
          return;
        } catch (logError) {
          retryCount++;
          print("Error while sending logs (attempt $retryCount): $logError");
          await Future.delayed(
            Duration(
              minutes: retryCount,
            ),
          );
        }
      }
      print("Failed to send logs after $maxRetries attempts");
      return;
    }
  } catch (loggingError, loggingStack) {
    print("Error while sending error to logs channel: $loggingError");
    print(loggingStack);
  }
}
