import 'dart:convert';
import 'dart:io';

class AdminFile {
  /// Admin File path
  static const filePath = ".televerse/admin.json";

  /// Creates the admin file if it doesn't exist
  static AdminFile create() {
    File adminFile = File(filePath);
    if (!adminFile.existsSync()) {
      adminFile.createSync();
      adminFile.writeAsStringSync("{}");
    }

    return AdminFile();
  }

  /// Broadcast message
  String? message;

  /// ID of the user who created the broadcast
  int? createdBy;

  /// Time at which the broadcast was created
  DateTime? createdAt;

  AdminFile({
    this.message,
    this.createdBy,
    this.createdAt,
  });

  static AdminFile? read() {
    File adminFile = File(filePath);
    if (!adminFile.existsSync()) {
      return null;
    }
    final admin = jsonDecode(adminFile.readAsStringSync());
    return AdminFile(
      message: admin["message"],
      createdBy: admin["createdBy"],
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (admin["createdAt"] ?? 0) * 1000,
      ),
    );
  }

  /// Update the admin file
  Future<void> saveToFile() async {
    File adminFile = File(filePath);
    if (!adminFile.existsSync()) {
      adminFile.createSync();
    }
    await adminFile.writeAsString(JsonEncoder.withIndent('  ').convert({
      "message": message,
      "createdBy": createdBy,
      "createdAt": (createdAt?.millisecondsSinceEpoch ?? 0) ~/ 1000,
    }));
  }
}
