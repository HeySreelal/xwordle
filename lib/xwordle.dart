library xwordle;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart';
import 'package:televerse/telegram.dart' hide File;
import 'package:televerse/televerse.dart';

part 'config/config.dart';
part 'config/consts.dart';
part 'config/day.dart';
part 'config/words.dart';
part 'handlers/admin.dart';
part 'handlers/error.dart';
part 'handlers/feedback.dart';
part 'handlers/guess.dart';
part 'handlers/help.dart';
part 'handlers/meaning.dart';
part 'handlers/next.dart';
part 'handlers/notify.dart';
part 'handlers/profile.dart';
part 'handlers/quit.dart';
part 'handlers/shape.dart';
part 'handlers/start.dart';
part 'handlers/update.dart';
part 'models/admin.dart';
part 'models/user.dart';
part 'services/db.dart';
part 'services/dict.dart';
part 'utils/utils.dart';
part 'handlers/cancel.dart';
part 'handlers/settings.dart';

final bot = Bot(WordleConfig.instance.token);
Conversation conv = Conversation(bot);
