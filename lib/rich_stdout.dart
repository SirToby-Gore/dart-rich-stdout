import 'dart:io';

class Terminal {
  int width = () {
    try {
      return stdout.terminalColumns;
    } catch (_) {
      return 0;
    }
  }();

  int height = () {
    try {
      return stdout.terminalLines;
    } catch (_) {
      return 0;
    }
  }();

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
    bool resetStyle = true,
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
    print(
      message,
      effects: [Colour.foregroundRed, Effect.bold],
      newLine: newLine,
    );
  }

  void warning(String message, {bool newLine = true}) {
    print(
      message,
      effects: [Colour.foregroundYellow, Effect.bold],
      newLine: newLine,
    );
  }

  void success(String message, {bool newLine = true}) {
    print(
      message,
      effects: [Colour.foregroundGreen, Effect.bold],
      newLine: newLine,
    );
  }

  void info(String message, {bool newLine = true}) {
    print(
      message,
      effects: [Colour.foregroundBlue, Effect.bold],
      newLine: newLine,
    );
  }

  String input(
    String text, {
    List<int> effects = const [],
    bool newLine = true,
    bool resetStyle = true,
    bool Function(String) check = Terminal.defaultInputCheck,
  }) {
    text = '${Ansi.construct(effects)}$text';

    if (resetStyle) {
      text += Ansi.construct([Effect.reset]);
    }

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

  void table(
    dynamic object, {
    Map<String, List<int>>? colourPairings,
    String tab = '  ',
    int indent = 0,
  }) {
    final pairings =
        colourPairings ??
        {
          'str': [Colour.foregroundGreen],
          'int': [Colour.foregroundBlue],
          'float': [Colour.foregroundBlue],
          'bool': [Colour.foregroundYellow],
          'dict': [Colour.foregroundLightBlue, Effect.faint],
          'list': [Colour.foregroundLightBlue, Effect.faint],
          'set': [Colour.foregroundPurple, Effect.faint],
          'tuple': [Colour.foregroundPurple, Effect.faint],
        };

    String getStrType(dynamic data) {
      if (data is String) return 'str';
      if (data is int) return 'int';
      if (data is double) return 'float';
      if (data is bool) return 'bool';
      if (data is Map) return 'dict';
      if (data is List) return 'list';
      if (data is Set) return 'set';
      return data.runtimeType.toString();
    }

    String typeColourPair(String typeStr) {
      final codes = pairings[typeStr] ?? [];
      return Ansi.construct(codes);
    }

    late String Function(dynamic, int) formatData;

    List<String> formatKeyValues(
      Iterable<dynamic> keys,
      Iterable<dynamic> values,
      int currentIndent,
    ) {
      final lines = <String>[];
      final keyList = keys.toList();
      final valueList = values.toList();

      for (var i = 0; i < keyList.length; i++) {
        final kStr = formatData(keyList[i], currentIndent);
        final vStr = formatData(valueList[i], currentIndent);
        lines.add((tab * currentIndent) + kStr + ': ' + vStr + ',');
      }
      return lines;
    }

    List<String> formatIterable(Iterable<dynamic> data, int currentIndent) {
      final lines = <String>[];
      for (var subData in data) {
        lines.add(
          (tab * currentIndent) + formatData(subData, currentIndent) + ',',
        );
      }
      return lines;
    }

    formatData = (dynamic data, int currentIndent) {
      final typeStr = getStrType(data);
      String string = typeColourPair(typeStr);

      switch (typeStr) {
        case 'str':
          string += '"$data"';
          break;
        case 'int':
        case 'float':
          string += data.toString();
          break;
        case 'bool':
          string += data ? 'TRUE' : 'FALSE';
          break;
        case 'dict':
          final mapData = data as Map;
          string +=
              '''{${Ansi.construct([Effect.reset])}\n${formatKeyValues(mapData.keys, mapData.values, currentIndent + 1).join('\n')}\n${tab * currentIndent}${typeColourPair('dict')}}''';
          break;
        case 'list':
          final listData = data as Iterable;
          string +=
              '''[${Ansi.construct([Effect.reset])}\n${formatIterable(listData, currentIndent + 1).join('\n')}\n${tab * currentIndent}${typeColourPair('list')}]''';
          break;
        case 'set':
          final setData = data as Set;
          string +=
              '''{${Ansi.construct([Effect.reset])}\n${formatIterable(setData, currentIndent + 1).join('\n')}\n${tab * currentIndent}${typeColourPair('set')}}''';
          break;
        default:
          string += data.toString();
      }

      string += Ansi.construct([Effect.reset]);
      return string;
    };

    this.print(formatData(object, indent));
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
  static const int defaultForeground = 39;

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
