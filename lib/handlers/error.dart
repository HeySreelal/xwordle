Future<void> errorHandler(Object err, StackTrace stack) {
  print('Caught error: $err');
  print(stack);
  return Future.value();
}
