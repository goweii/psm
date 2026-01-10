import 'package:args/command_runner.dart';
import 'package:psm/src/tasks/get_current_flavors_task.dart';
import 'package:psm/src/tasks/get_flavor_dependiencies_task.dart';
import 'package:psm/src/tasks/list_available_flavors_task.dart';
import 'package:psm/src/utils/logger.dart';
import 'package:psm/src/utils/project.dart';

class ListCommand extends Command {
  @override
  String get name => 'list';

  @override
  String get description => 'List all available flavors';

  ListCommand() {
    argParser.addFlag(
      'show-dependency',
      abbr: 'd',
      help: 'Show YAML dependency',
      defaultsTo: false,
      negatable: false,
    );
  }

  late bool showDependency = () {
    return argResults!['show-dependency'] as bool;
  }();

  @override
  Future<void> run() async {
    final project = Project.current();

    final currentFlavor = await GetCurrentFlavorsTask(project).run();
    final availableFlavors = await ListAvailableFlavorsTask(project).run();
    final flavorDependiencies = <String, List<String>>{};
    if (showDependency) {
      for (final flavor in availableFlavors) {
        final dependiencies = await GetFlavorDependienciesTask(
          project: project,
          flavor: flavor,
        ).run();
        flavorDependiencies[flavor] = dependiencies;
      }
    }

    if (availableFlavors.length > 1) {
      Logger.success('There are ${availableFlavors.length} flavors available:');
    } else {
      Logger.success('There is ${availableFlavors.length} flavor available:');
    }

    for (var flavor in availableFlavors) {
      final isCurrent = currentFlavor == flavor;
      final buffer = StringBuffer();
      if (isCurrent) {
        buffer.write('* $flavor');
      } else {
        buffer.write('  $flavor');
      }
      if (showDependency) {
        final depends = flavorDependiencies[flavor];
        if (depends != null && depends.length > 1) {
          buffer.write(' -> ');
          buffer.write(depends.skip(1).join(' -> '));
        }
      }
      if (isCurrent) {
        Logger.info(buffer.toString());
      } else {
        Logger.log(buffer.toString());
      }
    }
  }
}
