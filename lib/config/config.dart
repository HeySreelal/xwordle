import 'dart:io';

import 'package:televerse/televerse.dart';

void main(List<String> args) {
  print(WordleConfig.isDebug);
}

class WordleConfig {
  //? Change this to true to run in debug mode
  static bool get isDebug => false;

  String token;
  ChatID logsChannel;
  List<ChatID> adminChats;

  WordleConfig(
    this.token,
    this.logsChannel,
    this.adminChats,
  );

  factory WordleConfig.fromMap(Map<String, dynamic> map) {
    return WordleConfig(
      map['token'],
      ChatID(map['logs_channel']),
      map['admin_chats'].map((e) => ChatID(e)).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'token': token,
      'logs_channel': logsChannel.id,
      'admin_chats': adminChats.map((e) => e.id).toList(),
    };
  }

  static WordleConfig? _instance;

  static WordleConfig get instance {
    _instance ??= init();
    return _instance!;
  }

  static WordleConfig init() {
    if (isDebug) {
      print('Running in debug mode');
    }

    _instance = WordleConfig(
      isDebug ? env["TEST_TOKEN"] : env['TOKEN']!,
      ChatID(int.parse(env['LOGS']!)),
      (env['ADMINS']!.split(',') as List<String>)
          .map((e) => ChatID(int.parse(e)))
          .toList(),
    );
    return _instance!;
  }

  static Map<String, dynamic> get env {
    File file = File('.env');
    if (!file.existsSync()) {
      throw Exception('.env file not found');
    }
    String contents = file.readAsStringSync();
    final lines = contents.split('\n');
    String token = lines
        .firstWhere((element) => element.startsWith('TOKEN='))
        .split('=')[1];
    String logs = lines
        .firstWhere((element) => element.startsWith('LOGS='))
        .split('=')[1];
    String admins = lines
        .firstWhere((element) => element.startsWith('ADMINS='))
        .split('=')[1];
    String testToken = lines
        .firstWhere((element) => element.startsWith('TEST_TOKEN='))
        .split('=')[1];
    return {
      'TOKEN': token,
      'LOGS': logs,
      'ADMINS': admins,
      "TEST_TOKEN": testToken,
    };
  }
}
