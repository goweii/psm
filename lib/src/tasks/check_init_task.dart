import 'package:psm/src/tasks/base/task.dart';
import 'package:psm/src/utils/project.dart';

/// Task that checks if the project has already been initialized for flavor management
class CheckInitTask extends Task<bool> {
  /// Creates a new instance of [CheckInitTask]
  const CheckInitTask(this.project);

  final Project project;

  /// Checks if the project has been initialized by verifying if pubspec.yaml is a symbolic link
  /// Returns true if the project is already initialized, false otherwise
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
