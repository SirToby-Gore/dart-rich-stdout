import 'package:rich_stdout/rich_stdout.dart';

void main() {
  Terminal terminal = Terminal();
  terminal.print(
    'hello world',
    effects: [
      Effect.slowBlink,
      Colour.foregroundRed,
      Effect.bold,
    ],
  );
  terminal.endOfFile();
}
