## 1.3.2

- Admin must manually update words with `/update` command
- Changed the way notifications are sent
- Why? Outlined here: https://github.com/HeySreelal/xwordle/pull/103 

## 1.3.1

- Some fixes around broadcasting
- Shared some free hints info
- Changed the way notifications are sent
- Deprecated the `WordleDB.getUsers` because it used to get all documents in the players collection
- Changed the way notifications are sent.

## 1.3.0

- 🌬️ Improved error handling, fetcher configs, and more by @HeySreelal in
  https://github.com/HeySreelal/xwordle/pull/90
- ⚡️ Added Hints by @HeySreelal in https://github.com/HeySreelal/xwordle/pull/95
- 🎁 Removed crypto donation by @HeySreelal in
  https://github.com/HeySreelal/xwordle/pull/96
- Completes the invite related things by @HeySreelal in
  https://github.com/HeySreelal/xwordle/pull/98
- 🚀 Updated the `eval` method by @HeySreelal in
  https://github.com/HeySreelal/xwordle/pull/99

## 1.2.0

- Updated coloring logic to whole new one
- Improved performance
- Now uses Firebase Firestore as Databaes
- Supports inline queries for basic functionalities
- Accepting donations from now on
- Moved to Webhook for getting updates

## 1.1.1

- Meaning of the word 📖
- Auto Mute 🔕
- Counts meaning checks 📖
- Customisable hint shapes 💚🟨⚫️
- User feedback is important! 👩🏻‍⚖️
- Updated daily logging & Fix #38
- New broadcast, cancellation & quit
- Error log to logsChannel 👀
- Meaning & refactors ❤️‍🔥
- Improved Notifications
- Fix [#8](https://github.com/HeySreelal/xwordle/issues/8): Updated coloring
  logic 🚀
- Fix [#20](https://github.com/HeySreelal/xwordle/issues/20)
- Fix [#17](https://github.com/HeySreelal/xwordle/issues/17) - only for people
  who recently played
- Fix [#27](https://github.com/HeySreelal/xwordle/issues/27) - cause i remember
  it all too well

## 1.1.0

- Admin can request statistics of the game
- Daily logging
- Improved code quality

## 1.0.1

- 🆕 Added `/meaning` command to get meaning of the word
- Fix: /quit wasn't completely functional
- Update: Error handling is updated

## 1.0.0

- Initial version.
- The Wordle game inspired by the
  [Wordle game](https://www.nytimes.com/games/wordle/index.html) from the New
  York Times as Telegram bot.
- Every day a new word is generated.
