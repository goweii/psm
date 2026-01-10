import 'package:psm/src/tasks/base/task.dart';
import 'package:psm/src/utils/project.dart';
import 'package:psm/src/utils/pubspec_utils.dart';

class GetFlavorDependienciesTask extends Task<List<String>> {
  const GetFlavorDependienciesTask({
    required this.project,
    required this.flavor,
  });

  final Project project;
  final String flavor;

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
