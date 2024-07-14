import 'dart:convert';

import 'package:televerse/televerse.dart';
import 'package:xwordle/xwordle.dart';

void main(List<String> args) async {
  final id = 815030149;
  final user = await WordleUser.init(id);
  user.hints.addPlan(Plan.kickStartBundle);
  await user.save();

  // Edit this, and gift hints :)
  final updateMessage = "";

  final message = await api.sendMessage(
    ChatID(id),
    updateMessage,
  );
  print(JsonEncoder.withIndent('  ').convert(message.toJson()));
}
