// I know this is shit :)
// But, just to keep all the strings in one place

class MessageStrings {
  static const List<String> mustBe5Letters = [
    "Your guess must be 5 letters long",
    "Your guess must be a five-letter word.",
    "Your guess must be five letters long, or else you're wrong.",
    "Your guess must be five letters long, or you'll be left hanging.",
  ];
  static const List<String> mustBeLetters = [
    "Your guess must be letters only",
    "Your guess must only contain letters.",
    "Your guess must be made up of only letters.",
    "Your guess cannot contain any numbers, symbols, or spaces.",
    "Please enter a word that only contains letters.",
    "Your guess must be a word of only letters.",
  ];
  static const List<String> notValidWord = [
    "Uh, oh! I don't think that's a valid word.",
    "I don't think that's a real word.",
    "That word doesn't exist.",
    "I'm not sure what you mean by that.",
    "That's not a word in the dictionary.",
  ];

  /// **Not On Game Message**
  ///
  /// These are the messages that are sent when the user is not playing the game and sends some message to the bot.
  static const notOnGameMessages = [
    "You are not currently playing the game. 😇 Send /start to start playing. 🤖",
    "Oops! You're not on a game. Send /start to start play today's Wordle! 🤖",
    "First, send /start to start playing today's Wordle! 🤖",
    "I didn't get what you said. Send /start to start playing today's Wordle! 🤖",
    "Could you rephrase that, please? Send /help for help message, or /start to start playing. 👀",
    "Let's start the game or need some help? Send /help for help message, or /start to start playing. 😇",
  ];

  static const alreadyPlaying =
      "You are already playing the game. Shoot the guesses. 😇";
  static const notOnGame = "You are not currently playing the game. 😇";
  static const letsStart =
      "Let's start the game, shoot your first guess!\n\nMeanwhile, send <code>/help</code> anytime if you want to check instructions.";

  /// When bot tries to send message to the user who has blocked the bot.
  static const blocked = "Forbidden: bot was blocked by the user";

  /// Something went wrong
  static const somethingWentWrong =
      "Something went wrong. Please try again later.";

  /// When the bot is not allowed to initiate conversation with the user.
  static const cannotInitiate =
      "Forbidden: bot can't initiate conversation with a user";

  /// **Help Message**
  ///
  /// Sent when the user sends /help.
  static const helpMessage = """
💁‍♀️ <b>Help</b>

The game is about guessing a five letter word. You will have 6 tries to guess the word.
After each guess, you will get a hint about how many letters are in the word and how many are correct. 

Examples: 
Guess: WORLD
Hint: 🟩 ⬛️ ⬛️ ⬛️ ⬛️

Here W is correct, and no other letters are in the word. 

Guess: OPENS
Hint: 🟩 🟨 🟩 ⬛️ ⬛️

In this, O and E are in the word and at correct position, P is in the word but on a different position, but not in the correct position.

🔔 <b>New Word & Notifications</b>
A new word will be available every day. The bot will send you notification when the word is available. You can handle notification preference by sending /notify command.

📱 <b>Available Commands</b>
/start - Start the game
/notify - Enable/Disable notifications
/help - Show this help message
/about - Show about message
/quit - Quit the current game (Resets your streak)
/profile - Show your profile and stats

Happy Wordleing! 🤓
""";

  /// **About Message**
  ///
  /// Sent when the user sends /about.
  static const aboutMessage = """<b>🧑🏻‍💻 About</b>

Wordle Bot is Telegram bot version of the <a href="https://www.nytimes.com/games/wordle/index.html">Wordle</a> game.
Created by @HeySreelal with ❤️ for Telegram.

The bot is open source and source is available on <a href="https://github.com/HeySreelal/xwordlebot">GitHub</a>. Feel free to contribute.

Show some love by sharing the bot with your friends!

<a href="https://twitter.com/HeySreelal">Twitter</a> | <a href="https://t.me/xooniverse">Xooniverse</a>
""";

  /// **Notification Messages**
  ///
  /// Contains all the messages that are sent to the user as reminder to play the game.
  static const notificationMsgs = [
    "Hey, time to play! New Wordle is here!\nRemember to send /start to start playing. 👀",
    "New new new! 🆕 New Wordle is here!\nSend /start to start playing. 🤖",
    "New Wordle is here! 🆕\n\nSend /start to start playing. 🤖",
    "👀 Did your best friend tell you about today's Wordle?\n\nSend /start to start playing. 🤖",
    "New drop! 📨 New Wordle is here!\n\nSend /start to start playing. 🤖",
  ];

  /// **Excited Messages**
  ///
  /// Messages to be sent when the user tries to play the game again after it's over.
  static const excitedMessages = [
    "Excited? But, you've already played today! Next wordle showing up on {TIME} 👀",
    "You've already played today! Next wordle showing up on {TIME} 🤖",
    "I'm glad you're excited for this! 😍 Next wordle showing up on {TIME} 🤖",
    "Daily one wordle, that's the rule! 🤓 So next up on {TIME} 🤖",
    "Counting, 1, 2, 3... 🤓 Next Wordle arrives on {TIME} 🤖",
  ];

  /// **Welcome Messages**
  ///
  /// Messages to be sent when the user first joins the chat.
  static const welcomeMessages = [
    "Welcome to Wordle! Glad to have you here <b>{name}</b>! 🤓",
    "Welcome to Wordle Bot, {name}! 🤖 Let's play today's Wordle! 🚀",
    "Hey there, {name}! Greetings from Wordle Bot! 🚀",
  ];

  /// Notification prompt
  static const notificationPrompt =
      "Do you want to receive notifications when new word is available?";

  /// Perfect game messages
  static const perfectGameMessages = [
    "You're a natural!",
    "That was a total no-brainer!",
    "You're acing this game!",
    "You're on fire!",
    "You're acing this game like a boss!",
    "You're a pro!",
    "You're a master of this game!",
    "You're a total genius!",
    "You're acing this game like it's your job!",
    "Awesome! Just in one try! Nailed it! 🎉",
  ];
}
