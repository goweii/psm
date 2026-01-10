import 'dart:io';

import 'package:ansicolor/ansicolor.dart';

class Logger {
  Logger._();

  static final _penRed = AnsiPen()..red();
  static final _penYellow = AnsiPen()..yellow();
  static final _penBlue = AnsiPen()..blue();
  static final _penGreen = AnsiPen()..green();

  static bool verbose = false;

  static void trace(String message, {bool newLine = true}) {
    if (verbose) {
      if (newLine) {
        stdout.writeln(message);
      } else {
        stdout.write(message);
      }
    }
  }

  static void log(String message, {bool newLine = true}) {
    if (newLine) {
      stdout.writeln(message);
    } else {
      stdout.write(message);
    }
  }

  static void info(String message, {bool newLine = true}) {
    if (newLine) {
      stdout.writeln(_penBlue(message));
    } else {
      stdout.write(_penBlue(message));
    }
  }

  static void success(String message, {bool newLine = true}) {
    if (newLine) {
      stdout.writeln(_penGreen(message));
    } else {
      stdout.write(_penGreen(message));
    }
  }

  static void warning(String message, {bool newLine = true}) {
    stdout.writeln(_penYellow(message));
    if (newLine) {
      stdout.writeln(_penYellow(message));
    } else {
      stdout.write(_penYellow(message));
    }
  }

  static void error(
    String message, {
    bool newLine = true,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final buffer = StringBuffer();
    buffer.write(message);
    if (error != null) {
      buffer.write(': $error');
    }
    if (stackTrace != null) {
      buffer.write('\n$stackTrace');
    }
    if (newLine) {
      stderr.writeln(_penRed(buffer));
    } else {
      stderr.write(_penRed(buffer));
    }
  }
}
