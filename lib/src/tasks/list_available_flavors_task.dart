import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:psm/src/tasks/base/task.dart';
import 'package:psm/src/utils/project.dart';
import 'package:psm/src/utils/pubspec_utils.dart';

/// Task that lists all available flavors in the project
/// Searches the project directory for flavor-specific pubspec files
class ListAvailableFlavorsTask extends Task<List<String>> {
  /// Creates a new instance of [ListAvailableFlavorsTask]
  const ListAvailableFlavorsTask(this.project);

  final Project project;

  /// Executes the task to list available flavors
  /// Scans the project directory for files matching the flavor pubspec pattern
  /// Returns a list of available flavor names
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
