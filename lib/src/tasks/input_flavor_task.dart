import 'dart:io';

import 'package:psm/src/tasks/base/task.dart';
import 'package:psm/src/utils/exceptions.dart';
import 'package:psm/src/utils/logger.dart';
import 'package:psm/src/utils/pubspec_utils.dart';

/// Task that prompts the user to input a flavor name
/// Validates the input to ensure it meets the required format
class InputFlavorTask extends Task<String> {
  /// Creates a new instance of [InputFlavorTask]
  const InputFlavorTask();

  /// Executes the task to get flavor name from user input
  /// Prompts the user for input and validates the entered flavor name
  /// Returns 'base' if no input is provided
  @override
  Future<String> run() async {
    try {
      Logger.info('Please input flavor name (default: base): ', newLine: false);
      String flavor = stdin.readLineSync() ?? '';
      if (flavor.isEmpty) {
        flavor = 'base';
      } else {
        if (!PubspecUtils.checkFlavorName(flavor)) {
          throw TipsException('Invalid flavor name.');
        }
      }
      return flavor;
    } catch (e) {
      rethrow;
    }
  }
}
