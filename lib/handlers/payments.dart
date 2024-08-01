part of '../xwordle.dart';

Handler preCheckoutHandler() {
  return (ctx) async {
    await ctx.answerPreCheckouQuery(true);
    sendLogs(
      'Precheckout Query Received\n\n<pre><code class="language-json">${ctx.preCheckoutQuery?.toJson()}</code></pre>',
    ).ignore();
  };
}
