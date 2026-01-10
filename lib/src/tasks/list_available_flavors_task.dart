import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:psm/src/tasks/base/task.dart';
import 'package:psm/src/utils/project.dart';
import 'package:psm/src/utils/pubspec_utils.dart';

class ListAvailableFlavorsTask extends Task<List<String>> {
  const ListAvailableFlavorsTask(this.project);

  final Project project;

  @override
  Future<List<String>> run() async {
    try {
      final favors = <String>[];
      final fileList = project.rootDir.listSync().whereType<File>();
      for (var file in fileList) {
        final basename = p.basename(file.path);
        final flavor = PubspecUtils.getFlavorFromPubspecName(basename);
        if (flavor.isNotEmpty) {
          favors.add(flavor);
        }
      }
      return favors;
    } catch (e) {
      rethrow;
    }
  }
}
