## 1.0.0

- Initial version.
- Implemented `Terminal` class with methods for styling text output, including `print`, `error`, `warning`, `success`, and `info`.
- Added cursor manipulation methods: `moveCursor`, `moveCursorUp`, `moveCursorDown`, `moveCursorLeft`, and `moveCursorRight`.
- Included `clear`, `clearLine`, `hideCursor`, and `showCursor` methods for terminal management.
- Developed `input` method with customizable input checks.
- Introduced `Ansi` class with `construct` method for generating ANSI escape codes.

# 1.0.2

- Added `rows` and `columns`

# 1.0.3

- Changed name of `rows` and `columns` to `width` and `height`
- Updated the `endOfFile`
- Added new property `newLineItem`

# 1.0.4

- Bug fix `height` and `width` had each others values

# 1.0.5

- Fixing issue with a new line when initialising `Terminal`
- Added the ability to put in a custom `IOSink` (default is `stdout`) for the output, however `width` and `height` are still tied to `stdout`