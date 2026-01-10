import 'dart:io';

import 'package:psm/src/tasks/base/task.dart';
import 'package:psm/src/utils/exceptions.dart';
import 'package:psm/src/utils/logger.dart';
import 'package:psm/src/utils/pubspec_utils.dart';

class InputFlavorTask extends Task<String> {
  const InputFlavorTask();

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
