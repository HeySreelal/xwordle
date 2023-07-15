import 'dart:io';

import 'package:televerse/televerse.dart';
import 'package:xwordle/models/user.dart';

Bot<WordleUser> bot = Bot<WordleUser>(Platform.environment['BOT_TOKEN']!);
