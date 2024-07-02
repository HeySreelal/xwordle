part of '../xwordle.dart';

final app = FirebaseAdminApp.initializeApp(
  WordleConfig.env["PROJECT_ID"],
  Credential.fromServiceAccount(
    File("service-account.json"),
  ),
);

final db = Firestore(app);
