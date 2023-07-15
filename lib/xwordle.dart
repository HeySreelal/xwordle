import 'package:televerse/televerse.dart';
import 'package:xwordle/config/config.dart';
import 'package:xwordle/models/user.dart';

Bot<WordleUser> bot = Bot<WordleUser>(WordleConfig.instance.token);
