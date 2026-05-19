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

  terminal.table({
    'item 1': [
      8.9,
      true, 
      'new string',
      7,
    ]
  });
  terminal.endOfFile();
}
