import 'package:dart_firebase_admin/firestore.dart';
import 'package:televerse/televerse.dart';
import 'package:xwordle/xwordle.dart';

Future<bool> rewardUser(int uid) async {
  try {
    await db.doc("players/$uid").update({
      "hints.extraAttempts.left": FieldValue.increment(3),
      "hints.letterReveals.left": FieldValue.increment(3),
    });
    return true;
  } catch (_) {
    return false;
  }
}

Future<bool> isUserAMember(int uid) async {
  try {
    final result = await api.getChatMember(ChannelID("@xooniverse"), uid);
    return result.status == ChatMemberStatus.member ||
        result.status == ChatMemberStatus.administrator ||
        result.status == ChatMemberStatus.creator;
  } catch (err) {
    return false;
  }
}

void main(List<String> args) async {
  logToFile("Getting started!");
  final allusers = await WordleDB.getAllUsers();

  logToFile("We have ${allusers.length} people to talk to.");

  for (int i = 1821; i < allusers.length; i++) {
    final u = allusers[i];
    logToFile("Processing user #${i + 1}: ($u)");
    final c = ChatID(u);
    final isMem = await isUserAMember(u);
    if (!isMem) {
      logToFile("    > ❌ User is NOT member!");
      try {
        await api.sendMessage(
          c,
          "🗞️ Limited Time Offer! ⏳ Want some FREE hints? Nothing fancy, simply join our Xooniverse channel and snag your EXCLUSIVE hint pack before they're gone!",
          replyMarkup: InlineKeyboard()
              .addUrl("@Xooniverse", "https://t.me/+j3IPHw2RODQyYjE5"),
        );
        logToFile("    > ✅ Sent the offer to the user.!");
      } catch (err) {
        logToFile("    > 💥 We have an error: $err");
      }
      await Future.delayed(Duration(seconds: 3));
      logToFile("    > Wait is over. Moving on.");
      continue;
    }
    logToFile("    > So, user is a member.");
    final done = await rewardUser(u);
    if (done) {
      logToFile("    > 🔥 Rewarded the user! 🎉");
      try {
        await api.sendMessage(
          c,
          "🎉 You have been credited with SPECIAL Bonus Hints Pack with Letter Reveal x3 and Extra Attempt x3!\n\n<blockquote>Woohoo! Thanks you so much for being a part of @Xooniverse! We're happy to have you. Here's a little something to show our appreciation! 🎉</blockquote>",
          messageEffectId: kPartyEffectId,
          parseMode: ParseMode.html,
        );
      } catch (err) {
        logToFile("    > 💥 Rewarded, but couldn't notify them! $err");
      }
      await Future.delayed(Duration(seconds: 3));
    } else {
      logToFile("    > Oops.  We couldn't reward the user: $u");
    }
    logToFile("    > 😇 Done, moving on!");
  }

  logToFile("Process finished!");
}
