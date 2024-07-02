part of '../xwordle.dart';

/// A transformer for Televerse that automatically sends chat actions
/// based on the invoking method.
///
/// Suppose, if you're sending a message to the user with:
///
/// ```dart
///   ctx.reply("Hello World");
/// ```
///
/// Wouldn't it be nice to have the `"typing..."` chat action automatically sent?
/// This plugin does exactly that.
///
/// The `AutoChatAction` class implements the `Transformer` interface
/// and is used to send chat actions such as typing, uploading photos, etc.,
/// based on the specified API method.
///
/// When a method is invoked, if it is in the list of allowed methods and
/// not in the list of disallowed methods, a corresponding chat action is sent.
///
/// The class provides three properties:
/// - `allowedMethods`: A list of API methods that are allowed to send chat actions.
/// - `disallowedMethods`: A list of API methods that are not allowed to send chat actions.
/// - `interval`: The duration between repeated chat action sends, if the process is not yet completed.
class AutoChatAction implements Transformer {
  /// A list of API methods that are allowed to send chat actions.
  final List<APIMethod> allowedMethods;

  /// A list of API methods that are not allowed to send chat actions.
  final List<APIMethod> disallowedMethods;

  /// The duration between repeated chat action sends.
  final Duration interval;

  /// Class representing an instance of `AutoChatAction`.
  ///
  /// This class is used to configure and manage the automatic sending of chat actions within a chat interface.
  ///
  /// The constructor allows you to specify the following:
  ///
  /// * **[allowedMethods]:** This is a list of API methods that are allowed
  /// to send chat actions. Defaults to a list containing methods for sending
  /// various content types like videos, documents, stickers, voice messages,
  /// text messages, locations, video notes, and photos. If you provide a list
  /// here, only methods included in this list will be allowed to trigger chat
  /// actions.
  ///
  ///   Defaults to list containing:
  ///   - `APIMethod.sendVideo`
  ///   - `APIMethod.sendDocument`
  ///   - `APIMethod.sendSticker`
  ///   - `APIMethod.sendVoice`
  ///   - `APIMethod.sendMessage`
  ///   - `APIMethod.sendLocation`
  ///   - `APIMethod.sendVideoNote`
  ///   - `APIMethod.sendPhoto`
  ///
  /// ---
  ///
  /// * **[disallowedMethods]:** This is a list of API methods that are
  /// explicitly prohibited from sending chat actions. Defaults to an empty
  /// list. If you provide a list here, any method included in this list will
  /// be prevented from triggering chat actions regardless of their presence
  /// in the `allowedMethods` list.
  ///
  /// ---
  ///
  /// * **[interval]:**
  /// This defines the time interval between repeated automatic sending of
  /// chat actions. Defaults to 3 seconds. This value determines the minimum
  /// time gap between consecutive chat actions sent through this mechanism.
  ///
  /// Example usage:
  ///
  /// ```dart
  /// const autoChatAction = AutoChatAction(
  ///   allowedMethods: [APIMethod.sendMessage, APIMethod.sendPhoto],
  ///   disallowedMethods: [APIMethod.sendVoice],
  ///   interval: Duration(seconds: 5),
  /// );
  /// ```
  ///
  /// Now attach it with the bot like:
  /// ```dart
  /// bot.use(autoChatAction);
  /// ```
  ///
  /// In this example, automatic chat actions will only be sent for `sendMessage` and `sendPhoto` methods. The `sendVoice` method is explicitly disallowed, and the interval between repeated actions is set to 5 seconds.
  const AutoChatAction({
    this.allowedMethods = const [
      APIMethod.sendVideo,
      APIMethod.sendDocument,
      APIMethod.sendSticker,
      APIMethod.sendVoice,
      APIMethod.sendMessage,
      APIMethod.sendLocation,
      APIMethod.sendVideoNote,
      APIMethod.sendPhoto,
    ],
    this.disallowedMethods = const [],
    this.interval = const Duration(seconds: 3),
  });

  @override
  Future<Map<String, dynamic>> transform(
    APICaller call,
    APIMethod method,
    Payload payload,
  ) async {
    // If the method is not a send method, then just return
    if (!APIMethod.sendMethods.contains(method)) {
      return call(method, payload);
    }

    // If the method is not allowed to send chat action, ignore
    final notInAllowed = !allowedMethods.contains(method);
    final inDisallowed = disallowedMethods.contains(method);

    if (notInAllowed || inDisallowed) {
      return call(method, payload);
    }

    final action = switch (method) {
      APIMethod.sendVideo => ChatAction.uploadVideo,
      APIMethod.sendDocument => ChatAction.uploadDocument,
      APIMethod.sendSticker => ChatAction.chooseSticker,
      APIMethod.sendVoice => ChatAction.uploadVoice,
      APIMethod.sendMessage => ChatAction.typing,
      APIMethod.sendLocation => ChatAction.findLocation,
      APIMethod.sendVideoNote => ChatAction.uploadVideoNote,
      APIMethod.sendPhoto => ChatAction.uploadPhoto,
      _ => null,
    };

    if (action == null) {
      return call(method, payload);
    }

    // Inner method to send chat action
    void sendChatAction() {
      call(
        APIMethod.sendChatAction,
        Payload.from(
          {
            "chat_id": payload["chat_id"],
            "action": action.value,
          },
        ),
      ).ignore();
    }

    // Send the chat action immediately
    sendChatAction();

    // Periodically send chat action if the process is not completed yet.
    final timer = Timer.periodic(
      interval,
      (t) => sendChatAction(),
    );

    try {
      return await call(method, payload);
    } finally {
      timer.cancel();
    }
  }
}
