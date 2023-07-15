import 'dart:io';

import 'package:televerse/televerse.dart';

class WordleConfig {
  String token;
  ChatID logsChannel;
  List<ChatID> adminChats;

  WordleConfig(this.token, this.logsChannel, this.adminChats);

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
    _instance = WordleConfig(
      env['TOKEN']!,
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
    String token = contents
        .split('\n')
        .firstWhere((element) => element.startsWith('TOKEN='))
        .split('=')[1];
    String logs = contents
        .split('\n')
        .firstWhere((element) => element.startsWith('LOGS='))
        .split('=')[1];
    String admins = contents
        .split('\n')
        .firstWhere((element) => element.startsWith('ADMINS='))
        .split('=')[1];
    return {
      'TOKEN': token,
      'LOGS': logs,
      'ADMINS': admins,
    };
  }
}
