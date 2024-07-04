part of '../xwordle.dart';

class WordleConfig {
  /// A flag indicating whether the bot should use Webhook
  static bool get isWebhook => env['FETCHER'] == 'webhook';

  /// Returns boolean value if bot is running in production mode
  static bool get isProduction => env['MODE'] == 'production';

  //? Returns true if not running in production mode
  static bool get isDebug => !isProduction;

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

  static Map<String, dynamic>? _env;

  static Map<String, dynamic> get env {
    if (_env != null) return _env!;

    final file = File('.env');
    if (!file.existsSync()) {
      throw Exception('.env file not found');
    }
    final lines = file.readAsLinesSync();

    /// Env Keys
    final keys = [
      "TOKEN",
      "TEST_TOKEN",
      "LOGS",
      "ADMINS",
      "MODE",
      "PROJECT_ID",
      "TON_ADDRESS",
      "SOL_ON_SOLANA",
      "SOL_ON_BEP20",
      "USDT_TRC20",
      "USDT_ON_TON",
      "FETCHER",
    ];

    final config = {for (var key in keys) key: _getVal(lines, key)};
    config["MODE"] ??= "debug";

    _env = config;
    return config;
  }

  static String? _getVal(List<String> lines, String key) {
    try {
      return lines
          .firstWhere((element) => element.startsWith('$key='))
          .split('=')[1];
    } catch (_) {
      return null;
    }
  }
}
