import 'package:televerse/televerse.dart';
import 'package:xwordle/config/config.dart';
import 'package:xwordle/models/session.dart';

Bot<WordleSession> bot = Bot<WordleSession>(WordleConfig.init().token);
