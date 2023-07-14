import 'dart:io';

import 'package:televerse/televerse.dart';
import 'package:xwordle/models/session.dart';

Bot<WordleSession> bot = Bot<WordleSession>(Platform.environment['BOT_TOKEN']!);
