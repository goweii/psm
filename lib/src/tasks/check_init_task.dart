import 'package:psm/src/tasks/base/task.dart';
import 'package:psm/src/utils/project.dart';

class CheckInitTask extends Task<bool> {
  const CheckInitTask(this.project);

  final Project project;

  @override
  Future<bool> run() async {
    try {
      final symbolicLinks = project.pubspecFile.resolveSymbolicLinksSync();
      return symbolicLinks != project.pubspecFile.absolute.path;
    } catch (e) {
      rethrow;
    }
  }
}
