library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dart_firebase_admin/dart_firebase_admin.dart';
import 'package:dart_firebase_admin/firestore.dart';
import 'package:http/http.dart';
import 'package:televerse/telegram.dart' hide File;
import 'package:televerse/televerse.dart';

part 'config/config.dart';
part 'config/consts.dart';
part 'config/day.dart';
part 'config/fire.dart';
part 'config/words.dart';
part 'handlers/admin.dart';
part 'handlers/cancel.dart';
part 'handlers/error.dart';
part 'handlers/feedback.dart';
part 'handlers/guess.dart';
part 'handlers/help.dart';
part 'handlers/meaning.dart';
part 'handlers/next.dart';
part 'handlers/notify.dart';
part 'handlers/profile.dart';
part 'handlers/quit.dart';
part 'handlers/settings.dart';
part 'handlers/shape.dart';
part 'handlers/start.dart';
part 'handlers/update.dart';
part 'models/admin.dart';
part 'models/user.dart';
part 'services/auto_chat_action.dart';
part 'services/db.dart';
part 'services/dict.dart';
part 'utils/utils.dart';
part 'handlers/donate.dart';

late Bot bot;
late Conversation conv;

Future<void> init() async {
  final server = await HttpServer.bind(InternetAddress.anyIPv6, 8080);
  final webhook = WordleConfig.isDebug
      ? LongPolling.allUpdates()
      : Webhook(
          server,
          shouldSetWebhook: false,
          allowedUpdates: UpdateType.values,
        );
  bot = Bot(WordleConfig.instance.token, fetcher: webhook);
  conv = Conversation(bot);
}
