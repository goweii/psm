import 'package:path/path.dart' as p;
import 'package:psm/src/tasks/base/task.dart';
import 'package:psm/src/utils/project.dart';
import 'package:psm/src/utils/pubspec_utils.dart';

import 'check_init_task.dart';

/// Task that retrieves the currently active flavor in the project
class GetCurrentFlavorsTask extends Task<String?> {
  /// Creates a new instance of [GetCurrentFlavorsTask]
  const GetCurrentFlavorsTask(this.project);

  final Project project;

  /// Executes the task to get the current flavor
  /// Returns the name of the current flavor or null if none is set
  @override
  Future<String?> run() async {
    if (!await CheckInitTask(project).run()) {
      return null;
    }
    final symbolicLinks = project.pubspecFile.resolveSymbolicLinksSync();
    final filename = p.basename(symbolicLinks);
    final flavor = PubspecUtils.getFlavorFromMergedPubspecName(filename);
    if (flavor.isEmpty) {
      return null;
    }
    return flavor;
  }
}
