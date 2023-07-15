import 'dart:io';

import 'package:televerse/televerse.dart';
import 'package:xwordle/models/session.dart';

Bot<WordleUser> bot = Bot<WordleUser>(Platform.environment['BOT_TOKEN']!);
