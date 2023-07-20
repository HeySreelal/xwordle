part of xwordle;
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
    "I searched through all my knowledge, and couldn't find that word. Try another.",
    "That's not a word in the dictionary. Give it another try.",
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
/next - Shows time left for next word
/meaning - Get the meaning of the word
/profile - Show your profile and stats
/shape - Change the shape of the hint
/feedback - Send feedback to the developer
/help - Show this help message
/about - Show about message
/settings - Show settings
/quit - Quit the current game

Happy Wordleing! 🤓
""";

  /// **About Message**
  ///
  /// Sent when the user sends /about.
  static const aboutMessage = """<b>🧑🏻‍💻 About</b>

Wordle Bot is Telegram bot version of the <a href="https://www.nytimes.com/games/wordle/index.html">Wordle</a> game.
Created by @HeySreelal with ❤️ for Telegram.

The bot is open source and source is available on <a href="https://github.com/HeySreelal/xwordle">GitHub</a>. Feel free to contribute.

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
    "The next Wordle will be available in {TIME}.",
    "The next Wordle is just {TIME} away. Get ready to flex your vocabulary muscles",
    "The next Wordle is coming soon. Try gussing the word before it appears in {TIME}?",
    "The next Wordle is just {TIME} away. I guess you can wait that long.",
    "Counting, 1, 2, 3... 🤓 Next Wordle arrives on {TIME} 🤖",
  ];

  /// Already Played
  static const alreadyPlayed = [
    "You have already played today's Wordle. The next Wordle will be available in {DURATION}.",
    "Sorry, you can only play Wordle once a day. The next Wordle will be available in {DURATION}.",
    "You have already used up your daily Wordle. Please wait for {DURATION} for the next Wordle.",
    "You have already solved today's Wordle. The next Wordle will be available in {DURATION}.",
    "You have already guessed today's Wordle. The next Wordle will be available in {DURATION}.",
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

  static const meaningBeforePlayingResponse = [
    "You haven't solved today's Wordle yet! Once you do, I'll tell you what it means. 🎲",
    'You have not played today\'s wordle yet! Once you finish, you can get the meaning of the word. 🤓',
    "The answer to today's Wordle is under lock and key until you solve it. Good luck! 🔐",
    "I'm not giving away the meaning of today's Wordle until you've solved it. You're on your own, kid. 😉",
    "The meaning of today's Wordle is a mystery to me... until you solve it. So get to work! 🤓",
    "I'm dying to tell you what today's Wordle is, but I'm not telling you until you've solved it. Muahahaha! 😈",
  ];

  static const meaningError = [
    "I'm sorry, I couldn't find the meaning of that word. Please try again later.",
    "Oops, I could't find meaning from the dictionary. Please try again later.",
    "I'm sorry, I couldn't find the meaning of that word. Please try again later.",
  ];

  static const shapesPrompts = [
    "What shape would you like your hints to be? Choose from the keyboard. Or, you can let me surprise you by pressing the Random button.",
    "Choose your hint shape from the following: circle, square, or heart. Or, if you're feeling adventurous, press the Random button.",
  ];

  static const feedbackPrompts = [
    "Are there any features you would like to see added to the Wordle Bot?",
    "What do you think of the difficulty level of the Wordle Bot? Or write me anything on your mind.",
    "If you could add one feature to the bot, what would it be? Feel free to write me anything.",
    "Let me know your thoughts, may be what about answering: what is one thing you wish the bot did better?",
    "Sure, let me know your thoughts. What is your favorite thing about Wordle Bot?",
    "Do you think the bot is challenging enough? Or feel free to shoot your suggestion.",
  ];

  /// Cancel
  static const cancel = [
    "To cancel {ACTION}, simply type /cancel.",
    "If you've changed your mind, you can always cancel {ACTION} by typing /cancel.",
    "Not sure what to do next? Just type /cancel to cancel the current command.",
    "Need to change your mind? No problem! Just type /cancel to cancel the current command.",
    "Made a mistake? No worries! Just type /cancel to start over.",
  ];

  /// Nothing to cancel
  static const nothingToCancel = [
    "I don't think you're doing anything that can be canceled right now.",
    "You don't have anything to cancel.",
    "You're not currently doing anything that can be canceled.",
    "I'm not sure what you're trying to cancel.",
    "Can you please clarify what you're trying to cancel?",
  ];
}
