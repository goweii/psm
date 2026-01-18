import 'package:psm/src/tasks/base/task.dart';
import 'package:psm/src/utils/project.dart';
import 'package:psm/src/utils/pubspec_utils.dart';

/// Task that retrieves the dependency chain for a specific flavor
class GetFlavorDependienciesTask extends Task<List<String>> {
  /// Creates a new instance of [GetFlavorDependienciesTask]
  const GetFlavorDependienciesTask({
    required this.project,
    required this.flavor,
  });

  final Project project;
  final String flavor;

  /// Executes the task to get flavor dependencies
  /// Returns a list of flavors that the specified flavor depends on
  @override
  Future<List<String>> run() async {
    try {
      final filename = PubspecUtils.getPubspecNameByFlavor(flavor);
      final dependiencies = PubspecUtils.getDependencyFromPubspecName(filename);
      return dependiencies
          .map((e) => PubspecUtils.getFlavorFromPubspecName(e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
