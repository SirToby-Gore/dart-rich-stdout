import 'dart:io';

class Terminal {  
  int width = stdout.terminalColumns;
  int height = stdout.terminalLines;
  String newLineItem = stdout.lineTerminator;

  IOSink outputPoint = stdout;
  bool _firstLine = true;

  Terminal([IOSink? outputPoint]) {
    this.outputPoint = outputPoint ?? this.outputPoint;
  }

  void print(
    String text, {
      List<int> effects = const [],
      bool newLine = true,
      bool resetStyle = true
  }) {
    if (_firstLine) {
      _firstLine = false;
      newLine = false;
    }

    text = '${Ansi.construct(effects)}$text';
    
    if (resetStyle) {
      text += Ansi.construct([Effect.reset]);
    }

    if (newLine) {
      outputPoint.write(newLineItem);
    }

    outputPoint.write(text);
  }

  void error(String message, {bool newLine = true}) {
    print(message, effects: [Colour.foregroundRed, Effect.bold], newLine: newLine);
  }

  void warning(String message, {bool newLine = true}) {
    print(message, effects: [Colour.foregroundYellow, Effect.bold], newLine: newLine);
  }

  void success(String message, {bool newLine = true}) {
    print(message, effects: [Colour.foregroundGreen, Effect.bold], newLine: newLine);
  }
  
  void info(String message, {bool newLine = true}) {
    print(message, effects: [Colour.foregroundBlue, Effect.bold], newLine: newLine);
  }

  String input(
    String text, {
      List<int> effects = const [],
      bool newLine = true,
      bool resetStyle = true,
      bool Function(String) check = Terminal.defaultInputCheck,
  }) {
    text = '${Ansi.construct(effects)}$text';

    text += Ansi.construct([Effect.reset]);
    
    if (newLine) {
      outputPoint.write(newLineItem);
    }

    while (true) {
      outputPoint.write(text);

      String? input = stdin.readLineSync();

      if (input == null) {
        continue;
      }

      if (check(input)) {
        return input;
      }
    }
  }

  static bool defaultInputCheck(String input) {
    if (input.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  void endOfFile() {
    print('', resetStyle: true, newLine: !_firstLine);
    showCursor();
  }

  void clear() {
    outputPoint.write('\x1B[2J');
  }

  void clearLine() {
    outputPoint.write('\x1B[2K');
  }

  void hideCursor() {
    outputPoint.write('\x1B[?25l');
  }

  void showCursor() {
    outputPoint.write('\x1B[?25h');
  }

  void moveCursor(int x, int y) {
    outputPoint.write('\x1B[$y;${x}H');
  }

  void moveCursorUp(int y) {
    outputPoint.write('\x1B[${y}A');
  }

  void moveCursorDown(int y) {
    outputPoint.write('\x1B[${y}B');
  }

  void moveCursorLeft(int x) {
    outputPoint.write('\x1B[${x}D');
  }

  void moveCursorRight(int x) {
    outputPoint.write('\x1B[${x}C');
  }
}

class Ansi {
  static Colour colour = Colour();
  static Font font = Font();
  static Effect effect = Effect();
  static Ideogram ideogram = Ideogram();

  static String construct(List<int> effects) {
    return '\x1B[${effects.join(';')}m';
  }
}

class Colour {
  static const int foregroundBlack = 30;
  static const int foregroundRed = 31;
  static const int foregroundGreen = 32;
  static const int foregroundYellow = 33;
  static const int foregroundBlue = 34;
  static const int foregroundPurple = 35;
  static const int foregroundLightBlue = 36;
  static const int foregroundWhite = 37;

  static const int setForeground = 38;
  static const int setDefault = 39;

  static const int backgroundBlack = 40;
  static const int backgroundRed = 41;
  static const int backgroundGreen = 42;
  static const int backgroundYellow = 43;
  static const int backgroundBlue = 44;
  static const int backgroundPurple = 45;
  static const int backgroundLightBlue = 46;
  static const int backgroundWhite = 47;

  static const int setBackground = 48;
  static const int defaultBackground = 49;
}

class Font {
  static const int setDefault = 10;

  static const int font_1 = 11;
  static const int font_2 = 12;
  static const int font_3 = 13;
  static const int font_4 = 14;
  static const int font_5 = 15;
  static const int font_6 = 16;
  static const int font_7 = 17;
  static const int font_8 = 18;
  static const int font_9 = 19;
  static const int fraktur = 20;
}

class Effect {
  static const int reset = 0;
  static const int bold = 1;
  static const int faint = 2;
  static const int italic = 3;
  static const int underlined = 4;
  static const int slowBlink = 5;
  static const int rapidBlink = 6;
  static const int swapForeAndBack = 7;
  static const int conceal = 8;
  static const int strikeThrough = 9;

  static const int boldOrDoubleUnderline = 21;
  static const int normalFontWeight = 22;
  
  static const int notItalicNotFraktur = 23;

  static const int underlineOff = 24;
  static const int blinkOff = 25;
  static const int inverse = 27;
  static const int reveal = 28;
  static const int notStrikeThrough = 29;


  static const int framed = 51;
  static const int encircled = 52;
  static const int overlined = 53;
  static const int notFramedNotEncircled = 54;
  static const int notOverlined = 55;
}

class Ideogram {
  static const int underline = 60;
  static const int doubleUnderline = 61;
  static const int overline = 62;
  static const int doubleOverline = 63;
  static const int stressMarking = 64;
  static const int attributesOff = 65;
}


