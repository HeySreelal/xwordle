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

// Configs
part 'config/config.dart';
part 'config/consts.dart';
part 'config/day.dart';
part 'config/fire.dart';
part 'config/words.dart';

// Handlers
part 'handlers/admin.dart';
part 'handlers/cancel.dart';
part 'handlers/donate.dart';
part 'handlers/error.dart';
part 'handlers/feedback.dart';
part 'handlers/guess.dart';
part 'handlers/help.dart';
part 'handlers/hints.dart';
part 'handlers/inline.dart';
part 'handlers/meaning.dart';
part 'handlers/next.dart';
part 'handlers/notify.dart';
part 'handlers/privacy.dart';
part 'handlers/profile.dart';
part 'handlers/quit.dart';
part 'handlers/settings.dart';
part 'handlers/shape.dart';
part 'handlers/start.dart';
part 'handlers/update.dart';

// Models
part 'models/admin.dart';
part 'models/hint_shape.dart';
part 'models/premium_hints.dart';
part 'models/pricing_plans.dart';
part 'models/user.dart';

// Services
part 'services/auto_chat_action.dart';
part 'services/db.dart';
part 'services/dict.dart';

// Utils
part 'utils/utils.dart';

/// The Raw API instance.
final api = RawAPI(WordleConfig.instance.token);

late Bot bot;
late Conversation conv;

/// Initializes the Bot with set fetcher
Future<void> init() async {
  if (WordleConfig.isWebhook) {
    final server = await HttpServer.bind(InternetAddress.anyIPv6, 8080);
    final webhook = Webhook(
      server,
      shouldSetWebhook: false,
      allowedUpdates: UpdateType.values,
    );
    bot = Bot.fromAPI(api, fetcher: webhook);
  } else {
    final longPoll = LongPolling.allUpdates();
    bot = Bot.fromAPI(api, fetcher: longPoll);
  }

  conv = Conversation(bot);
}
